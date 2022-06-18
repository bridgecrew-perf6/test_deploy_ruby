class CostRevenue < ActiveRecord::Base
  include UpcaseAttributes
  include ActionView::Helpers::NumberHelper

  OPENED = 0.freeze
  COMPLETED = 1.freeze

  # attr_accessor :si_no, :to, :vessel, :port_of_loading, :destination, :bl_si_number, :shipper, :shipper_reference, :etd, :volume, :payment_number
  # attr_accessor :default_selling_vat_1, :default_selling_pph_23, :default_selling_total_invoice, :default_npt
  
  with_options touch: true do |assoc|
    assoc.belongs_to :shipping_instruction
    assoc.belongs_to :shipper
    assoc.belongs_to :consignee
    assoc.belongs_to :owner
    # assoc.belongs_to :author, class_name: "User", foreign_key: "create_by"
  end

  with_options dependent: :destroy do |assoc|
    assoc.has_many :cr_containers    
    assoc.has_many :cost_revenue_items

    assoc.has_many :fixed_items, -> { where(item_type: 0) }, class_name: "CostRevenueItem"
    assoc.has_many :active_items, -> { where(item_type: 1) }, class_name: "CostRevenueItem"
    assoc.has_many :volume_items, -> { where(item_type: 2) }, class_name: "CostRevenueItem"
    assoc.has_many :shipper_items, -> { where(item_type: 3) }, class_name: "CostRevenueItem"
    assoc.has_many :carrier_items, -> { where(item_type: 4) }, class_name: "CostRevenueItem"
  end

  has_many :containers, :through => :cr_containers

  # IBL Ref, MBL No, Shipper Ref, Carrier, Shipper, Consignee, Trade, Owner, Vessel, Etd, POL, POD, Destination, Volume
  delegate :master_bl_no, :shipper_reference, :carrier, :shipper_id, :consignee_id, :shipper_company_name, :consignee_company_name, :trade, :first_vessel_name, :first_etd_date, :port_of_loading, :port_of_discharge, :final_destination, :volume, to: :shipping_instruction, prefix: :update, allow_nil: true
  delegate :ibl_ref_with_status, :first_etd_date, to: :shipping_instruction, allow_nil: true

  validates_presence_of :shipping_instruction_id

  scope :completed, -> { where(status: COMPLETED) }
  
  with_options allow_destroy: true do |nest_attr|
    nest_attr.accepts_nested_attributes_for :cr_containers
    nest_attr.accepts_nested_attributes_for :cost_revenue_items, :reject_if => lambda { |a| a[:description].blank? }
    
    nest_attr.accepts_nested_attributes_for :fixed_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :active_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :volume_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :shipper_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :carrier_items, :reject_if => lambda { |a| a[:description].blank? }
  end

  before_save :check_associations
  # before_save :set_carrier_id

  after_commit :generate_workers

  before_create :set_ibl_ref

  def set_ibl_ref
    self.ibl_ref = self.shipping_instruction.ibl_ref
  end

  def set_carrier_id
    self.carrier_id = Carrier.find_by(name: self.carrier).try(:id) if self.carrier_changed?
  end

  def self.initialize_new(params)
    charges = []
    fixed = []
    active = []
    volume = []
    shipper = []
    carrier = []
    cr_container = []
    items = []

    volume_type = { "LCL" => 0, 
                    "20FT" => 0, 
                    "40FT" => 0, 
                    "40HQ" => 0
                  }
    if si = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      # si.si_containers.each do |item|
      #   # charges << { description: item.container.container_type, selling_volume: item.volum, buying_volume: item.volum, item_type: 'volume' }
      #   volume << { description: item.container.container_type, selling_volume: item.volum, buying_volume: item.volum, item_type: 'volume' }
      #   cr_container << { container_id: item.container_id, volum: item.volum }
      # end

      si.si_containers.each do |item|
        # charges << { description: item.container.container_type, selling_volume: item.volum, buying_volume: item.volum, item_type: 'volume' }
        unless item.container.container_type == "Special Equipment" || item.container.container_type == "TYPE"
          volume_type[item.container.container_type] = item.volum
        end
        cr_container << { container_id: item.container_id, volum: item.volum } unless item.volum.blank?
      end

      # volume << { description: "LCL", selling_volume: volume_type["LCL"], buying_volume: volume_type["LCL"], item_type: 'volume' }
      # volume << { description: "OF 20\'", selling_volume: volume_type["20FT"], buying_volume: volume_type["20FT"], item_type: 'volume' }
      # volume << { description: "OF 40\'", selling_volume: volume_type["40FT"], buying_volume: volume_type["40FT"], item_type: 'volume' }
      # volume << { description: "OF 40HC", selling_volume: volume_type["40HQ"], buying_volume: volume_type["40HQ"], item_type: 'volume' }
      # volume << { description: "THC 20\'", selling_volume: 0, buying_volume: 0, item_type: 'volume' }
      # volume << { description: "THC 20\'", selling_volume: 0, buying_volume: 0, item_type: 'volume' }
      # volume << { description: "THC 40HC", selling_volume: 0, buying_volume: 0, item_type: 'volume' }
      items << { description: "LCL", selling_volume: volume_type["LCL"].to_f, buying_volume: volume_type["LCL"].to_f, item_type: 'volume' } unless volume_type["LCL"].to_f == 0
      items << { description: "OF 20\'", selling_volume: volume_type["20FT"].to_f, buying_volume: volume_type["20FT"].to_f, item_type: 'volume' } unless volume_type["20FT"].to_f == 0
      items << { description: "OF 40\'", selling_volume: volume_type["40FT"].to_f, buying_volume: volume_type["40FT"].to_f, item_type: 'volume' } unless volume_type["40FT"].to_f == 0
      items << { description: "OF 40HC", selling_volume: volume_type["40HQ"].to_f, buying_volume: volume_type["40HQ"].to_f, item_type: 'volume' } unless volume_type["40HQ"].to_f == 0
      items << { description: "THC 20\'", selling_volume: volume_type["20FT"].to_f, buying_volume: volume_type["20FT"].to_f, item_type: 'volume' } unless volume_type["20FT"].to_f == 0
      items << { description: "THC 40\'", selling_volume: volume_type["40FT"].to_f, buying_volume: volume_type["40FT"].to_f, item_type: 'volume' } unless volume_type["40FT"].to_f == 0
      items << { description: "THC 40HC", selling_volume: volume_type["40HQ"].to_f, buying_volume: volume_type["40HQ"].to_f, item_type: 'volume' } unless volume_type["40HQ"].to_f == 0
      
      # si.shipper.shipper_items.each do |item|
      #   # charges << { description: item.description, selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
      #   shipper << { description: item.description, selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
      # end

      # Carrier.find_by(name: si.carrier).carrier_items.each do |item|
      #   # charges << { description: item.description, selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
      #   carrier << { description: item.description, selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
      # end unless si.carrier.blank?

      unless si.shipper.blank?
        unless si.shipper.shipper_items.blank?
          si.shipper.shipper_items.each do |item|
            # shipper << { description: item.description, selling_usd: item.amount_usd, selling_idr: item.amount_idr, buying_usd: item.amount_usd, buying_idr: item.amount_idr, selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
            items << { description: item.description, selling_usd: item.amount_usd, selling_idr: item.amount_idr, selling_volume: 1, buying_volume: 0, item_type: 'shipper' }
          end
        else
          # shipper << { description: 'PEB', selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
          # shipper << { description: 'Fiat PEB', selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
          # shipper << { description: 'COO', selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
          # shipper << { description: 'Trucking', selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
          # shipper << { description: 'Fumigation', selling_volume: 1, buying_volume: 1, item_type: 'shipper' }
        end
      end

      si_carrier = Carrier.find_by(name: si.carrier)
      unless si_carrier.blank?
        unless si_carrier.carrier_items.blank?
          si_carrier.carrier_items.each do |item|
            # carrier << { description: item.description, selling_usd: item.amount_usd, selling_idr: item.amount_idr, buying_usd: item.amount_usd, buying_idr: item.amount_idr, selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
            items << { description: item.description, buying_usd: item.amount_usd, buying_idr: item.amount_idr, buying_volume: 1, selling_volume: 0, item_type: 'carrier' }
          end
        else
          # carrier << { description: 'Doc', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'Adm', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'Seal', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'AMS/ENS', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'Telex', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'Switch', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'Certificate', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
          # carrier << { description: 'SIA', selling_volume: 1, buying_volume: 1, item_type: 'carrier' }
        end
      end

      # charges << { description: "OTHER", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # charges << { description: "RATE", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # charges << { description: "VAT 10%", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # charges << { description: "VAT 1%", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # charges << { description: "PPH 23", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      
      # fixed << { description: "OTHER", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # fixed << { description: "RATE", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # fixed << { description: "VAT 10%", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # fixed << { description: "VAT 1%", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }
      # fixed << { description: "PPH 23", selling_volume: 1, buying_volume: 1, item_type: 'fixed' }

      CostRevenue.new(
        shipping_instruction: si, 

        ibl_ref: si.ibl_ref,

        # si_no: si.si_no, 
        master_bl_no: si.master_bl_no, 
        shipper_reference: si.shipper_reference, 
        carrier: si.carrier, 
        carrier_id: Carrier.find_by(name: si.carrier).try(:id),
        shipper: si.shipper, 
        consignee: si.consignee, 
        trade: si.trade, 
        vessel_name: si.first_vessel_name, 
        etd_date: si.first_etd_date, 
        port_of_loading: si.port_of_loading, 
        port_of_discharge: si.port_of_discharge, 
        final_destination: si.final_destination, 
        volume: si.volume, 
        cr_containers_attributes: cr_container,
        cost_revenue_items_attributes: items,
        # volume_items_attributes: volume,
        # shipper_items_attributes: shipper,
        # carrier_items_attributes: carrier,
        # active_items_attributes: active, 
        # fixed_items_attributes: fixed
      )
    else
      CostRevenue.new
    end
  end

  # def si_no
  #   self.shipping_instruction.si_no unless self.shipping_instruction.nil?
  # end

  # def shipper
  #   self.shipping_instruction.shipper.company_name unless self.shipping_instruction.shipper.nil?
  # end

  # def vessel
  #   # vessel = self.shipping_instruction.vessels.first
  #   # unless vessel.nil?
  #   #   vessel.vessel_name
  #   # end
  #   self.first_vessel
  # end

  # def destination
  #   self.shipping_instruction.final_destination unless self.shipping_instruction.nil?
  # end

  # def port_of_loading
  #   self.shipping_instruction.port_of_loading unless self.shipping_instruction.nil?
  # end

  # Revisi 1 Dec 2015
  def shipper_company_name
    self.shipper.company_name unless self.shipper.nil?
  end

  def consignee_company_name
    self.consignee.company_name unless self.consignee.nil?
  end

  def bl_si_number
    [self.shipping_instruction.si_no, self.shipping_instruction.master_bl_no].join(" / ") unless self.shipping_instruction.nil?
  end

  # def ibl_ref
  #   self.si_no
  # end

  # def shipper_reference
  #   self.shipping_instruction.shipper_reference unless self.shipping_instruction.nil?
  # end

  def payment_number
    # unless self.new_record?
    begin
      payment = []
      payments = Payment.includes(:payment_references).where(is_cancel: 0, payment_references: {ibl_ref: self.si_no}).references(:payment_references)
      payments.each do |p|
        payment.push(p.payment_no)
      end
      # payments = PaymentReference.references(:payment).where(ibl_ref: self.si_no)
      # .includes(:payment)
      # payments.each do |p|
      #   unless payment.include?(p.payment.payment_no)
      #     payment.push(p.payment.payment_no)
      #   end
      # end
      return payment.join("\n")
    rescue => e
      return ""
    end
    # end
    # ""
  end

  def new_payment_number

  end

  def etd
    vessel = self.shipping_instruction.vessels.first
    unless vessel.nil?
      # Revisi 26 October 2015
      # (vessel.etd_date).to_time.strftime('%d %B %Y')
      (vessel.etd_date).to_time.strftime('%d %B %Y') unless vessel.etd_date.blank?
    end
  end

  # def volume
  #   unless self.new_record?
  #     volume = []
  #       self.shipping_instruction.si_containers.each do |c|
  #         if c.container_type == "LCL"
  #               volume.push("#{number_with_precision(c.volum, precision: 3, delimiter: ',')} M3 #{c.container.container_type}")
  #         else
  #             volume.push(c.volum.to_s + "x" + c.container.container_type)
  #           end
  #       end
  #       return volume.join(" & ")
  #   end
  #   ""
  # end

  def total_selling_usd
    total = 0
    unless self.new_record?
      self.cost_revenue_items.each do |c|
        total += c.selling_usd.to_f
      end
    end
    total
  end

  def total_selling_idr
    total = 0
    unless self.new_record?
      self.cost_revenue_items.each do |c|
        total += c.selling_idr.to_f
      end
    end
    total
  end

  def total_buying_usd
    total = 0
    unless self.new_record?
      self.cost_revenue_items.each do |c|
        total += c.buying_usd.to_f
      end
    end
    total
  end

  def total_buying_idr
    total = 0
    unless self.new_record?
      self.cost_revenue_items.each do |c|
        total += c.buying_idr.to_f
      end
    end
    total
  end

  def total_profit_usd
    total_selling_usd - total_buying_usd
  end

  def total_profit_idr
    total_selling_idr - total_buying_idr
  end

  def is_open?
    status == 0
  end

  def is_completed?
    status == 1
  end

  def status_text
    str = []
    str.push "Open" if self.is_open?
    str.push "Completed" if self.is_completed?
    str
  end

  def completed?
    status == COMPLETED
  end

  def update_status(status)
    self.update_attribute(:status, status)
    self.shipping_instruction.update_attribute(:status, status)
  end

  def initialize_new_cost_revenue
  end

  def self.get_shipment_comparison(number)
    shipping_instruction = ShippingInstruction.find_by(si_no: number)

    if shipping_instruction.nil?
      @get_shipment_comparison = {success: false, message: "SI Not Listed"}
    else
      @get_shipment_comparison = begin
        {success: true, 
          master_bl_no: shipping_instruction.master_bl_no,
          shipper_reference: shipping_instruction.shipper_reference,
          carrier: shipping_instruction.carrier,
          carrier_name: shipping_instruction.carrier,
          carrier_id: Carrier.find_by(name: shipping_instruction.carrier).try(:id),
          shipper_id: shipping_instruction.shipper_id,
          shipper_company_name: shipping_instruction.shipper_company_name,
          consignee_id: shipping_instruction.consignee_id,
          consignee_company_name: shipping_instruction.consignee_company_name,
          trade: shipping_instruction.trade,

          vessel_name: shipping_instruction.first_vessel_name,
          etd_date: shipping_instruction.first_etd_date,
          port_of_loading: shipping_instruction.port_of_loading,
          port_of_discharge: shipping_instruction.port_of_discharge,
          final_destination: shipping_instruction.final_destination,
          volume: shipping_instruction.volume,
          si_containers: 
            shipping_instruction.si_containers.map.each do |si_container|
              { 
                container_id: si_container.container_id,
                volum: si_container.volum
              }
            end
        }
      end
    end

    @get_shipment_comparison
  end

  def volume
    str = self.cr_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "LCL"  ? "#{number_with_precision(c.volum, precision: 3, delimiter: ',')} M3 #{c.container.container_type}" : c.container.container_type.upcase != "TYPE" ? "#{c.volum}x#{c.container.container_type}": "") }.delete_if{|e| e.squish.length == 0}.join(" & ")
    type = self.cr_containers.map {|c| (c.container.container_type.upcase == "TYPE" ? c.volum : "" ) }
    [str, type].join(" ").squish
  end

  # def selling_lcl_other
  #   total = 0
  #   self.cost_revenue_items.each do |item|
  #     total += item.selling_total.to_f
  #   end
  #   total += self.selling_other.to_f

  #   total
  # end

  # def buying_lcl_other
  #   total = 0
  #   self.cost_revenue_items.each do |item|
  #     total += item.buying_total.to_f
  #   end
  #   total += self.buying_other.to_f

  #   total
  # end

  # def selling_vat_1
  #   (self.selling_lcl_other.to_f / 101).round(2)
  # end

  # def selling_pph_23
  #   (self.selling_lcl_other.to_f * (-0.02)).round(2)
  # end

  def sum_selling_total
    # total = 0
    # self.cost_revenue_items.each do |item|
    #   total += item.selling_total.to_f
    # end

    # total
    self.cost_revenue_items.map{|p| p.selling_total unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def sum_buying_total
    # total = 0
    # self.cost_revenue_items.each do |item|
    #   total += item.buying_total.to_f
    # end

    # total
    self.cost_revenue_items.map{|p| p.buying_total unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def sum_selling_total_after_tax
    # total = 0
    # self.cost_revenue_items.each do |item|
    #   total += item.selling_total_after_tax.to_f
    # end

    # total
    self.cost_revenue_items.map{|p| p.selling_total_after_tax unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def sum_buying_total_after_tax
    # total = 0
    # self.cost_revenue_items.each do |item|
    #   total += item.buying_total_after_tax.to_f
    # end

    # total
    self.cost_revenue_items.map{|p| p.buying_total_after_tax unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def default_selling_vat_1
    (self.sum_selling_total.to_f / 101).round(2)
  end

  def default_selling_vat_11
    (self.sum_selling_total.to_f / 101.1).round(2)
  end

  def default_selling_pph_23
    (self.sum_selling_total.to_f * (-0.02)).round(2)
  end

  def selling_total_invoice
    # (self.selling_lcl_other.to_f + self.selling_vat_10.to_f + self.selling_vat_1.to_f + self.selling_pph_23.to_f).round(2)
    (self.sum_selling_total_after_tax.to_f + self.selling_other.to_f + self.selling_vat_10.to_f + self.selling_vat_1.to_f + self.selling_pph_23.to_f).round(2)
  end

  def buying_total_invoice
    # (self.buying_lcl_other.to_f + self.buying_vat_10.to_f + self.buying_vat_1.to_f + self.buying_pph_23.to_f).round(2)
    # (self.sum_buying_total.to_f + self.buying_other.to_f + self.buying_vat_10.to_f + self.buying_vat_1.to_f - self.buying_pph_23.to_f).round(2)
    (self.sum_buying_total_after_tax.to_f + self.buying_other.to_f + self.buying_vat_10.to_f + self.buying_vat_1.to_f).round(2)
  end

  def default_selling_total_invoice
    (self.sum_selling_total.to_f + self.selling_other.to_f - self.selling_vat_10.to_f - self.default_selling_vat_1.to_f + self.default_selling_pph_23.to_f).round(2)
  end

  def default_buying_total_invoice
    # (self.sum_buying_total_after_tax.to_f + self.buying_other.to_f + self.buying_vat_10.to_f + self.buying_vat_1.to_f - self.buying_pph_23.to_f).round(2)
    (self.sum_buying_total.to_f + self.buying_other.to_f + self.buying_vat_10.to_f + self.buying_vat_1.to_f).round(2)
  end

  def addt
    (self.adda.to_f + self.addb.to_f + self.addc.to_f).round(2)
  end

  def gpt
    # (self.selling_total_invoice.to_f - self.buying_total_invoice.to_f).round(2)
    # (self.selling_total_invoice.to_f - self.default_buying_total_invoice.to_f).round(2)
    (self.selling_total_invoice.to_f - self.buying_total_invoice.to_f).round(2)
  end

  def npt
    (self.gpt.to_f - self.addt.to_f).round(2)
  end

  def default_npt
    # (self.default_selling_total_invoice.to_f - self.buying_total_invoice.to_f - self.addt.to_f).round(2)
    (self.default_selling_total_invoice.to_f - self.default_buying_total_invoice.to_f - self.addt.to_f).round(2)
  end

  def selling_currency
    currency = "IDR"
    currency = "USD" if (self.selling_rate.to_f == 0 && self.cost_revenue_items.map(&:selling_idr).sum(&:to_f) == 0)

    currency
  end

  def buying_currency
    currency = "IDR"
    currency = "USD" if (self.buying_rate.to_f == 0 && self.cost_revenue_items.map(&:buying_idr).sum(&:to_f) == 0)

    currency
  end

  def sell_usd
    str = []
    amount = self.cost_revenue_items.where(description: 'LCL').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{amount}/LCL" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{amount}/20'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{amount}/40'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{amount}/HQ" unless amount == 0
    str
  end

  def sell_idr
    str = []
    amount = self.cost_revenue_items.where(description: 'LCL').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{amount}/LCL" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{amount}/20'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{amount}/40'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{amount}/HQ" unless amount == 0
    str
  end

  def cost_usd
    str = []
    amount = self.cost_revenue_items.where(description: 'LCL').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{amount}/LCL" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{amount}/20'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{amount}/40'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{amount}/HQ" unless amount == 0
    str
  end

  def cost_idr
    str = []
    amount = self.cost_revenue_items.where(description: 'LCL').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{amount}/LCL" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{amount}/20'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{amount}/40'" unless amount == 0
    amount = self.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{amount}/HQ" unless amount == 0
    str
  end

  def owner_name
    self.owner.try(:name)
  end
  
  def carrier_name
    unless self.carrier_id.blank?
      Carrier.find(self.carrier_id).try(:name)
    # else
    #   self.shipping_instruction.carrier
    else
      self.shipping_instruction.carrier
    end
  end

  def volume_lcl
    str = self.cr_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "LCL" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_20ft
    str = self.cr_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "20FT" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_40ft
    str = self.cr_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "40FT" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_40hq
    str = self.cr_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "40HQ" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_type
    str = self.cr_containers.map {|c| (c.container.container_type.upcase == "TYPE" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end
  
  private
  def check_associations
    self.cr_containers.each do |container|
      unless container.container.container_type.upcase == "TYPE"
        container.mark_for_destruction if container.volum.to_f <= 0
      else
        container.mark_for_destruction if container.volum.blank?
      end
    end
  end

  def generate_workers
    # CrMonitoringWorker.perform_async(shipping_instruction_id)
    # # CommisionMonitoringWorker.perform_async(shipping_instruction_id)
    # SellCostMonitoringWorker.perform_async(shipping_instruction_id)
  end
end
