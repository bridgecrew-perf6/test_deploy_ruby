class ShippingInstruction < ActiveRecord::Base
  include UpcaseAttributes
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  attr_accessor :order_type_details, :duplicate_si

  UNCANCELED = 0.freeze
  CANCELED = 1.freeze

  OPENED = 0.freeze
  CLOSED = 1.freeze

  with_options touch: true do |assoc|
    assoc.belongs_to :shipper
    assoc.belongs_to :consignee
    assoc.belongs_to :author, class_name: "User", foreign_key: "create_by"
    assoc.belongs_to :handler, class_name: "User", foreign_key: "handle_by"
  end

  with_options dependent: :destroy do |assoc|
    assoc.has_one :bill_of_lading
    assoc.has_one :bill_of_lading_history
    assoc.has_one :cost_revenue
    assoc.has_one :shipment_tracking
    assoc.has_many :shipping_instruction_histories
    assoc.has_many :vessels, :inverse_of => :shipping_instruction
    assoc.has_many :si_containers
    assoc.has_many :attachments, :as => :assetable

    assoc.has_many :bill_of_lading_invoices
    assoc.has_many :payment_invoices
    
    assoc.has_many :payment_references, foreign_key: 'ibl_ref', primary_key: 'si_no'
    assoc.has_many :payments, through: :payment_references
    assoc.has_many :payment_deposits, foreign_key: 'ibl_deposit', primary_key: 'si_no'
  end

  has_many :containers, :through => :si_containers

  accepts_nested_attributes_for :bill_of_lading_invoices, :reject_if => lambda { |a| a[:is_ai].blank? && a[:is_gi].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :payment_invoices, :reject_if => lambda { |a| a[:payment_date].blank? && a[:carrier].blank? && a[:is_paid].blank? }, :allow_destroy => true

  validates_presence_of :shipper_id, :consignee_id, :shipper_name, :consignee_name
  validates_uniqueness_of :si_no, :message => "must be unique"

  # validate :check_bill_of_lading_invoices_rate

  with_options allow_destroy: true do |nest_attr|
    nest_attr.accepts_nested_attributes_for :vessels, :reject_if => lambda { |a| a[:vessel_name].blank? }
    nest_attr.accepts_nested_attributes_for :si_containers
    nest_attr.accepts_nested_attributes_for :attachments, :reject_if => lambda { |a| a[:name].blank? || a[:asset].blank? }
  end

  scope :open, -> { where(status: 0) }
  scope :close, -> { where(status: 1) }
  scope :recent, -> {
    # references(:shipper, :consignee)
    # .includes(:bill_of_lading, :vessels, {si_containers: [:container]}, :shipper, :consignee)
    order("shipping_instructions.si_no DESC")
  }
  scope :recent_cost_revenue, -> {
    # references(:shipper)
    # .includes({cost_revenue: [:cost_revenue_items]}, {si_containers: [:container]}, :vessels, :shipper)
    where(is_shadow: false).order("shipping_instructions.si_no DESC")
  }

  before_save :check_associations
  after_initialize :set_default_attributes
  after_commit :generate_workers
  after_save :generate_workers

  search_syntax do
    search_by :text do |scope, phrases|
      columns = [:si_no, :shipper_reference, :final_destination, :si_date, :carrier, :port_of_loading,
                 :master_bl_no, :order_details, "shippers.company_name", "consignees.company_name"]
      scope.where_like(columns => phrases)
    end
  end

  def check_bill_of_lading_invoices_rate
    valid = true
    self.bill_of_lading_invoices.each do |value|
      unless value.marked_for_destruction?
        valid = false if value.rate.to_f == 0
      end
    end
    errors.add(:base, "Please fill all rate. Thanks") unless valid
  end

  def initialize_new_si(year = Date.today.year)
    self.si_no = self.generate_new_si_number(year)
  end

  def initialize_add_si
    self.si_no = self.new_shadow_no
    self.etd_jkt = self.si_date_format(self.etd_jkt)
    self.etd_sin = self.si_date_format(self.etd_sin)
    self.eta = self.si_date_format(self.eta)
    self.si_date = self.si_date_format(self.si_date)
    self.inst_date = self.si_date_format(self.inst_date)
    self.is_shadow = true
  end

  def is_canceled?
    is_cancel == 1
  end

  def is_uncanceled?
    not is_canceled?
  end

  def is_open?
    status == 0
  end

  def is_closed?
    status == 1
  end

  def order_type_details
    self.order_details.split(";")
  end

  def order_type_details=(order_dets)
    new_order_dets = order_dets.reject!(&:empty?)
    if new_order_dets.nil?
      self.order_details = order_dets.join(";")
    else
      self.order_details = new_order_dets.join(";")
    end
  end

  def order_type_text
    order_type_text = ""

    filter_order = ["EXPORT", "IMPORT", "LOCAL", "OTHER"]
    unless self.order_type.empty?
      order_type_text += self.order_type if filter_order.include?(self.order_type)
    end

    unless self.order_details.empty?
      order_type_text += " ("
      if self.order_details.include?("OTHER")
        tmp = self.order_type_details
        tmp[tmp.length-1] = tmp[tmp.length-1].split("=")[1]
        order_type_text += tmp.join(", ")
      else
        order_type_text += self.order_type_details.join(", ")
      end
      order_type_text += ")"
    end
    order_type_text
  end

  # def shipper_name
  #   unless self.shipper_id.nil?
  #     # address_custom_fields = self.shipper.custom_fields.where(:field_key => "address") unless self.shipper_id.nil?
  #     shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
  #     # shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
  #     shipper_name += self.shipper.full_address unless self.shipper_id.nil?
  #   end
  # end

  # def consignee_name
  #   unless self.consignee_id.nil?
  #     consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
  #     consignee_name += self.consignee.full_address unless self.consignee_id.nil?
  #   end
  # end

  def update_shipper_name
    unless self.shipper_id.nil?
      # address_custom_fields = self.shipper.custom_fields.where(:field_key => "address") unless self.shipper_id.nil?
      tmp_shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
      # shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
      tmp_shipper_name += self.shipper.full_address unless self.shipper_id.nil?
      self.shipper_name = tmp_shipper_name
    end
  end

  def update_consignee_name
    unless self.consignee_id.nil?
      tmp_consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
      tmp_consignee_name += self.consignee.full_address unless self.consignee_id.nil?
      self.consignee_name = tmp_consignee_name
    end
  end

  def generate_new_si_number(year = Date.today.year)
    new_number = ""
    # if vessels.any?
    #   first_vessel = vessels.first
    #   year = first_vessel.etd_date.strftime("%y")
    # else
    #   year = Date.today.strftime("%y")
    # end

    # Revisi 19 Jan 2015
    if year.presence
      year = year.to_s[2..3]
    else
      year = Date.today.strftime("%y")
    end
    # End Revisi 19 Jan 2015

    si_count = ShippingInstruction.where(is_shadow: false).where("si_no LIKE ?", "IBL#{year}%").count

    if si_count == 0
      total = "10001"
      new_number = "IBL#{year}#{total[1..total.length - 1]}"
    else
      sum = 10000
      last_si = ShippingInstruction.where(is_shadow: false).where("si_no LIKE ?", "IBL#{year}%").order(si_no: :asc).last.si_no
      count = last_si[5..last_si.length - 1].to_i

      while sum <= count + 1
        sum = sum * 10
      end

      total = (sum + count + 1).to_s
      new_number = "IBL#{year}#{total[1..total.length - 1]}"
    end

    new_number
    # new_number = ""
    # si_count = ShippingInstruction.where("YEAR(created_at) = ? AND is_shadow = ?", Date.today.year, false).count
    # year = Date.today.year.to_s[2..3]
    #
    # if si_count == 0
    #   total = 10001.to_s
    #
    #   new_number = "IBL#{year}" + total[1..total.length-1]
    # else
    #   sum = 10000
    #   last_si = ShippingInstruction.where("YEAR(created_at) = ? AND is_shadow = ?", Date.today.year, false).last.si_no
    #   count = last_si[5..last_si.length-1].to_i
    #
    #   while sum <= count + 1
    #     sum = sum * 10
    #   end
    #
    #   total = (sum + count + 1).to_s
    #
    #   new_number = "IBL#{year}" + total[1..total.length-1]
    # end
    #
    # new_number
  end

  def new_shadow_no
    new_number = ""
    si_number = (self.is_shadow ? self.si_no[0..self.si_no.length-2] : self.si_no)
    si_count = ShippingInstruction.where("si_no LIKE ? AND is_shadow = ?", "%#{si_number}%", true).count
    if si_count == 0
      new_number = si_number + "A"
    else
      new_number = si_number + (65 + si_count).chr
    end
    new_number
  end

  def si_date_format(date_str)
    date_str.to_time.strftime('%d-%b-%Y') unless date_str.nil?
  end

  def is_complete
    completed = true
    # - Shipper
    # - Shipper's Reference
    # - Shipping Schedule (Etd & Eta)
    # - Volume
    # - Port of Loading
    # - Final Destination
    # - Feeder Vessel
    # - Booking No
    # - Master BL No

    # skip_attr = ["is_cancel", "order_type", "status", "updated_at", "created_at", "update_by", "create_by",
    #   "container_id", "volume", "eta", "etd_sin", "etd_jkt", "port_of_transhipment", "inst_date", "no_of_obl",
    #   "freight_details"]

    filter_attr = ["shipper_name", "port_of_loading", "booking_no", "master_bl_no", "shipper_reference"] #, "final_destination", "feeder_vessel"

    empty_field = []

    self.attributes.each do |attr_name, attr_value|
      if filter_attr.include?(attr_name)
        if attr_value.nil? || attr_value.blank?
          completed = false
          empty_field.push(attr_name.humanize.upcase)
        end
      end
    end

    if self.final_destination.nil? || self.final_destination.blank?
      completed = false
      empty_field.push("SCHEDULE (VESSEL, ETD, ETA, DESTINATION)")
    elsif self.feeder_vessel.nil? || self.feeder_vessel.blank?
      completed = false
      empty_field.push("SCHEDULE (VESSEL, ETD, ETA, DESTINATION)")
    elsif !self.vessels.any?
      completed = false
      empty_field.push("SCHEDULE (VESSEL, ETD, ETA, DESTINATION)")
    else
      temp1 = self.vessels.first
      temp2 = self.vessels.last
      if ((temp1.etd_date.nil? || temp1.vessel_name.nil? || temp1.etd_no.nil?) || (temp2.eta_date.nil? || temp2.vessel_name.nil? || temp2.eta_no.nil?))
        completed = false
        empty_field.push("SCHEDULE (VESSEL, ETD, ETA, DESTINATION)")
      end
    end
    # unless self.vessels.any?
    #   completed = false
    #   empty_field.push("SCHEDULE (VESSEL, ETD, ETA, DESTINATION)")
    # else
    #   temp1 = self.vessels.first
    #   temp2 = self.vessels.last
    #   if ((temp1.etd_date.nil? || temp1.vessel_name.nil? || temp1.etd_no.nil?) || (temp2.eta_date.nil? || temp2.vessel_name.nil? || temp2.eta_no.nil?))
    #     completed = false
    #     empty_field.push("SCHEDULE (VESSEL, ETD, ETA, DESTINATION)")
    #   end
    # end

    unless self.si_containers.any?
      completed = false
      empty_field.push("VOLUME / QUANTITY")
    end

    {:success => completed, :message => empty_field}
  end

  def first_etd_date
    # vessel = self.vessels.first
    # unless vessel.nil?
    #   vessel.etd_date
    # end
    # Revisi 1 Dec 2015
    self.vessels.first.etd_date unless self.vessels.blank?
  end

  def etd_date_first
    self.vessels.first.etd_date unless self.vessels.blank?
  end

  def last_eta_date
    # vessel = self.vessels.last
    # unless vessel.nil?
    #   vessel.eta_date
    # end
    # Revisi 1 Dec 2015
    self.vessels.last.eta_date unless self.vessels.blank?
  end

  def eta_date_last
    self.vessels.last.eta_date unless self.vessels.blank?
  end
  
  # Revisi 1 Dec 2015
  def shipper_company_name
    self.shipper.company_name unless self.shipper.nil?
  end

  def consignee_company_name
    self.consignee.company_name unless self.consignee.nil?
  end

  def volume
    # self.si_containers.map {|c| (c.container.container_type == "LCL" ? "#{number_with_precision(c.volum, precision: 3, delimiter: ',')} M3 #{c.container.container_type}" : "#{c.volum}x#{c.container.container_type}") }.join(" & ")
    str = self.si_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "LCL"  ? "#{number_with_precision(c.volum, precision: 3, delimiter: ',')} M3 #{c.container.container_type}" : c.container.container_type.upcase != "TYPE" ? "#{c.volum}x#{c.container.container_type}": "") }.delete_if{|e| e.squish.length == 0}.join(" & ")
    type = self.si_containers.map {|c| (c.container.container_type.upcase == "TYPE" ? c.volum : "" ) }
    [str, type].join(" ").squish
  end

  def bl_status
    if self.is_canceled?
      "Cancel"
    else
      self.bill_of_lading.blank? ? "On Going" : "Draft BL" 
    end
  end

  def shipping_schedule
    temp = ""
    self.vessels.each do |vessel|
      temp += (vessel.vessel_name.nil? ? "" : vessel.vessel_name.upcase) + "\r\n"
      temp += "Etd " + (vessel.etd_no.nil? ? "" : vessel.etd_no.upcase) + " : " + (vessel.etd_date.nil? ? "" : self.si_date_format(vessel.etd_date)) + "\r\n"
      temp += "Eta " + (vessel.eta_no.nil? ? "" : vessel.eta_no.upcase) + " : " + (vessel.eta_date.nil? ? "" : self.si_date_format(vessel.eta_date)) + "\r\n"
    end
    temp
  end

  def feeder
    self.vessels.first
  end

  def feeder_vessel
    self.feeder.vessel_name unless self.feeder.blank?
  end

  def destination
    self.vessels.last
  end

  def connecting
    if self.vessels.size >= 2
      self.vessels.last
    end
  end

  def transit_time
    if !self.destination.blank? && !self.feeder.blank?
      if !self.destination.eta_date.blank? && !self.feeder.etd_date.blank?
        (destination.eta_date - feeder.etd_date + 1).to_i
      end
    end
  end

  def vessel_name
    # self.vessels.map(&:vessel_name).delete_if{|e| e.squish.length == 0} unless self.vessels.blank?
    self.vessels.map(&:vessel_name).delete_if{|e| e.squish.length == 0}
  end

  def ibl_ref
    self.si_no
  end

  # def consignee_name
  #   self.consignee.company_name
  # end

  # def port_of_discharge
  #   self.final_destination
  # end

  # def destination
  # end

  def first_vessel_name
    # vessel = self.vessels.first
    # vessel.vessel_name unless vessel.blank?
    self.vessels.first.vessel_name unless self.vessels.blank?
  end

  def first_line_notify_party
    self.notify_party.lines.first.squish unless self.notify_party.blank?
  end

  def author_name
    self.author.username unless self.author.blank?
  end

  def handler_name
    unless self.handler.blank?
      self.handler.username
    else
      self.author_name
    end
  end

  def ibl_ref_with_status
    str = self.si_no
    str += " (Cancel)" if self.is_canceled?
    # str += " (Closed)" if self.is_closed?
    str
  end

  def status_text
    str = []
    str.push "Cancel" if self.is_canceled?
    str.push "Closed" if self.is_closed?
    str
  end

  def change_date_format
    self.etd_jkt = self.si_date_format(self.etd_jkt)
    self.etd_sin = self.si_date_format(self.etd_sin)
    self.eta = self.si_date_format(self.eta)
    self.si_date = self.si_date_format(self.si_date)
    self.inst_date = self.si_date_format(self.inst_date)
  end

  def create_original(user, year = Date.today.year)
    self.create_by = user.id
    self.update_by = user.id

    while ShippingInstruction.exists? si_no: self.si_no do
      self.si_no = self.generate_new_si_number(year)
    end

    if save
      # Revisi 19 Jan 2015
      # update(si_no: generate_new_si_number)
      # first_vessel = vessels.first
      # unless si_no.include? "IBL#{first_vessel.etd_date.strftime("%y")}"
      #   new_si_no = loop do
      #     tmp_si_no = generate_new_si_number(year)
      #     break tmp_si_no unless self.class.exists?(si_no: tmp_si_no)
      #   end
      #   update(si_no: new_si_no)
      # end
      # End Revisi 19 Jan 2015
      ShipmentTracking.find_or_create_by(shipping_instruction: self)
      true
    else
      false
    end
  end

  def create_additional_si(user)
    self.create_by = user.id
    self.update_by = user.id

    while ShippingInstruction.exists? si_no: self.si_no do
      self.si_no = self.new_shadow_no
    end

    save
  end

  def update_and_create_history(params, user)
    if valid?
      history = ShippingInstructionHistory.new
      history.populate_data(self)
      self.assign_attributes(params)
      
      if changed?
        self.update_by = user.id
        history.save
      end
    end

    save
  end

  def self.get_booking_no(number)
    shipping_instruction = find_by(si_no: number)

    if shipping_instruction.nil?
      @get_booking_no = {success: false, message: "SI Not Listed"}
    else
      @get_booking_no = begin
        if shipping_instruction.booking_no.nil? || shipping_instruction.booking_no.blank?
          {success: false, message: "Check Booking No #{shipping_instruction.ibl_ref}"}
        elsif shipping_instruction.status == 1
          {success: false, message: "C&R Completed"}
        else
          {success: true, booking_no: shipping_instruction.booking_no}
        end
      end
    end

    @get_booking_no
  end

  def self.get_master_bl_no(number)
    shipping_instruction = find_by(si_no: number)

    if shipping_instruction.nil?
      @get_master_bl_no = {success: false, message: "SI Not Listed"}
    else
      @get_master_bl_no = begin
        if shipping_instruction.bill_of_lading.blank?
          {success: false, message: "#{shipping_instruction.ibl_ref} has not yet Create BL"}
        elsif shipping_instruction.master_bl_no.nil? || shipping_instruction.master_bl_no.blank?
          {success: false, message: "Check Master BL No #{shipping_instruction.ibl_ref}"}
        elsif shipping_instruction.status == 1
          {success: false, message: "C&R Completed"}
        else
          {success: true, master_bl_no: shipping_instruction.master_bl_no}
        end
      end
    end

    @get_master_bl_no
  end

  def self.with_filter(params)
    shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, :handler, :bill_of_lading, :cost_revenue, si_containers: [ :container ]).recent
    shipping_instructions = shipping_instructions.search(params[:query]) unless params[:query].to_s.empty?
    shipping_instructions = shipping_instructions.where(is_cancel: 1) if params[:cancel].to_i == 1
    shipping_instructions = shipping_instructions.where(status: 1) if params[:closed].to_i == 1

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      shipping_instructions = shipping_instructions.where("si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
    end

    # shipping_instructions#.page(params[:page])
    if Rails.env.development?
      shipping_instructions.first(10)
    else
      shipping_instructions
    end
  end

  def self.get_cost_revenues(params)
    shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, :author, :bill_of_lading, cost_revenue: [ :cost_revenue_items ], si_containers: [ :container ]).recent_cost_revenue

    unless params[:query].to_s.empty?
      keys = [:si_no, :final_destination, "shippers.company_name"]
      shipping_instructions = shipping_instructions.where_like(keys => params[:query])
    end

    begin
      date = Date.parse(params[:dtpicker])
      shipping_instructions = shipping_instructions.joins("LEFT OUTER JOIN vessels VS ON (VS.id = (SELECT SVS.id FROM vessels SVS WHERE SVS.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
      .where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month,
             date.end_of_month)
    rescue Exception => e
      # ignored
    end

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      shipping_instructions = shipping_instructions.where("si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
    end

    # shipping_instructions#.page(params[:page])
    
    if Rails.env.development?
      shipping_instructions.first(10)
    else
      shipping_instructions
    end
  end

  def self.get_payments_plan(params)
    shipping_instructions = ShippingInstruction.includes(:shipper, :vessels, :bill_of_lading, payment_invoices: [ :payment_items ]).recent_cost_revenue

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      shipping_instructions = shipping_instructions.where("si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
    end

    if Rails.env.development?
      shipping_instructions.first(10)
    else
      shipping_instructions
    end
  end

  def self.get_payments_tax(params)
    shipping_instructions = ShippingInstruction.includes(:shipper, :vessels, :bill_of_lading, payment_invoices: [ :payment_items ]).recent_cost_revenue

    ids = PaymentInvoice.where(is_paid: true).pluck('distinct shipping_instruction_id')
    shipping_instructions = shipping_instructions.where(id: ids)

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      shipping_instructions = shipping_instructions.where("si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
    end

    if Rails.env.development?
      shipping_instructions.first(10)
    else
      shipping_instructions
    end
  end

  def duplicate_data(si)
    # self.si_no = si.si_no
    self.shipper_id = si.shipper_id
    self.consignee_id = si.consignee_id
    self.shipper_name = si.shipper_name
    self.consignee_name = si.consignee_name
    self.notify_party = si.notify_party
    self.country_of_origin = si.country_of_origin
    self.carrier = si.carrier
    self.pic = si.pic
    self.feeder_vessel = si.feeder_vessel
    self.connection_vessel = si.connection_vessel
    self.place_of_receipt = si.place_of_receipt
    self.port_of_loading = si.port_of_loading
    self.port_of_transhipment = si.port_of_transhipment
    self.port_of_discharge = si.port_of_discharge
    self.final_destination = si.final_destination
    self.no_of_obl = si.no_of_obl
    self.si_date = si.si_date
    self.marks_no = si.marks_no
    self.description_packages = si.description_packages
    self.gw = si.gw
    self.nw = si.nw
    self.measurement = si.measurement
    self.dimension = si.dimension
    self.freight = si.freight
    self.freight_details = si.freight_details
    self.special_instructions = si.special_instructions
    self.container_no = si.container_no
    self.container_no_2 = si.container_no_2
    self.peb_no = si.peb_no
    self.inst_date = si.inst_date
    self.kpbc = si.kpbc
    self.hs_code = si.hs_code
    # self.create_by = si.create_by
    # self.update_by = si.update_by
    self.shipper_reference = si.shipper_reference
    self.status = si.status
    self.order_type = si.order_type
    self.booking_no = si.booking_no
    self.master_l_no = si.master_l_no
    self.created_at = si.created_at
    self.updated_at = si.updated_at
    # Revisi 1 Dec 2015
    self.trade = si.trade
    self.handle_by = si.handle_by

    self.order_type_details = si.order_type_details

    si.vessels.each do |vessel|
      self.vessels.build( vessel_name: vessel.vessel_name, 
                          etd_no: vessel.etd_no, 
                          etd_date: vessel.etd_date, 
                          eta_no: vessel.eta_no, 
                          eta_date: vessel.eta_date)
    end
    si.si_containers.each do |si_container|
      self.si_containers.build( container_id: si_container.container_id,
                                volum: si_container.volum)
    end
  end

  def is_cancel?
    self.is_cancel == 1
  end

  def is_connecting?
    # # false
    # # true if !self.connecting.blank? && (!self.connecting.etd_date.blank? && self.connecting.etd_date == (Date.today + 2.days))
    # tmp = false
    # unless self.connecting.blank? 
    #   unless self.connecting.etd_date.blank?
    #     tmp = true if self.connecting.etd_date == (Date.today + 2.days)
    #   end
    # end
    # tmp
    tmp = false
    # unless self.connecting.blank?
      self.vessels.each_with_index do |vessel, index|
        unless index == 0
          unless vessel.etd_date.blank?
            len = (vessel.etd_date - DateTime.now.in_time_zone("Jakarta").to_date).to_i
            tmp = true if len >= 0 && len <= 2
          end
        end
      end
    # end
    tmp
  end

  def is_arrived?
    # # false
    # # true if !self.destination.blank? && (!self.destination.eta_date.blank? && self.destination.eta_date == (Date.today + 2.days))
    # tmp = false
    # unless self.destination.blank? 
    #   unless self.destination.eta_date.blank?
    #     tmp = true if self.destination.eta_date == (Date.today + 2.days)
    #   end
    # end
    # tmp
    tmp = false
    # unless self.destination.blank?
      self.vessels.each_with_index do |vessel, index|
        unless vessel.eta_date.blank?
          len = (vessel.eta_date - DateTime.now.in_time_zone("Jakarta").to_date).to_i
          tmp = true if len == 0
        end
      end
    # end
    tmp
  end

  def initialize_new_bill_of_lading_invoice
    charges = []
    fixed = []
    active = []
    volume = []
    shipper = []
    carrier = []
    items = []
    other = 0
    rate = 0
    # if si = ShippingInstruction.find(params[:sid])
    si = self
    if si.bill_of_lading_invoices.blank?
      if si.cost_revenue.blank?
        volume_type = { "LCL" => 0, 
                        "20FT" => 0, 
                        "40FT" => 0, 
                        "40HQ" => 0
                      }
        si.si_containers.each do |item|
          unless item.container.container_type == "Special Equipment" || item.container.container_type == "TYPE"
            volume_type[item.container.container_type] = item.volum
          end
          # volume << { description: item.container.container_type, volume: item.volum, item_type: 'volume' }
        end

        # volume << { description: "LCL", volume: volume_type["LCL"], item_type: 'volume' }
        # volume << { description: "OF 20\'", volume: volume_type["20FT"], item_type: 'volume' }
        # volume << { description: "OF 40\'", volume: volume_type["40FT"], item_type: 'volume' }
        # volume << { description: "OF 40HC", volume: volume_type["40HQ"], item_type: 'volume' }
        # volume << { description: "THC 20\'", volume: 0, item_type: 'volume' }
        # volume << { description: "THC 20\'", volume: 0, item_type: 'volume' }
        # volume << { description: "THC 40HC", volume: 0, item_type: 'volume' }
        items << { description: "LCL", volume: volume_type["LCL"].to_f, item_type: 'volume' } unless volume_type["LCL"].to_f == 0
        items << { description: "OF 20\'", volume: volume_type["20FT"].to_f, item_type: 'volume' } unless volume_type["20FT"].to_f == 0
        items << { description: "OF 40\'", volume: volume_type["40FT"].to_f, item_type: 'volume' } unless volume_type["40FT"].to_f == 0
        items << { description: "OF 40HC", volume: volume_type["40HQ"].to_f, item_type: 'volume' } unless volume_type["40HQ"].to_f == 0
        items << { description: "THC 20\'", volume: volume_type["20FT"].to_f, item_type: 'volume' } unless volume_type["20FT"].to_f == 0
        items << { description: "THC 40\'", volume: volume_type["40FT"].to_f, item_type: 'volume' } unless volume_type["40FT"].to_f == 0
        items << { description: "THC 40HC", volume: volume_type["40HQ"].to_f, item_type: 'volume' } unless volume_type["40HQ"].to_f == 0
        unless si.shipper.blank?
          unless si.shipper.shipper_items.blank?
            si.shipper.shipper_items.each do |item|
              # shipper << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, volume: 1, item_type: 'shipper' }
              items << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, volume: 1, item_type: 'shipper' }
            end
          else
            # shipper << { description: 'PEB', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'Fiat PEB', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'COO', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'Trucking', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'Fumigation', volume: 1, item_type: 'shipper' }
          end
        end

        si_carrier = Carrier.find_by(name: si.carrier)
        unless si_carrier.blank?
          unless si_carrier.carrier_items.blank?
            si_carrier.carrier_items.each do |item|
              # carrier << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, volume: 1, item_type: 'carrier' }
              items << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, volume: 1, item_type: 'carrier' }
            end
          else
            # carrier << { description: 'Doc', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Adm', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Seal', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'AMS/ENS', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Telex', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Switch', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Certificate', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'SIA', volume: 1, item_type: 'carrier' }
          end
        end

        # fixed << { description: "OTHER", volume: 1, item_type: 'fixed' }
        # fixed << { description: "RATE", volume: 1, item_type: 'fixed' }
        # fixed << { description: "VAT 10%", volume: 1, item_type: 'fixed' }
        # fixed << { description: "VAT 1%", volume: 1, item_type: 'fixed' }
        # fixed << { description: "PPH 23", volume: 1, item_type: 'fixed' }
      else
        cr = si.cost_revenue
        # cr.volume_items.each do |item|
        #   volume << { description: item.description, amount_usd: item.selling_usd, amount_idr: item.selling_idr, volume: item.selling_volume, item_type: 'volume' }
        # end
        # cr.shipper_items.each do |item|
        #   shipper << { description: item.description, amount_usd: item.selling_usd, amount_idr: item.selling_idr, volume: item.selling_volume, item_type: 'shipper' }
        # end
        # cr.carrier_items.each do |item|
        #   carrier << { description: item.description, amount_usd: item.selling_usd, amount_idr: item.selling_idr, volume: item.selling_volume, item_type: 'carrier' }
        # end
        # cr.active_items.each do |item|
        #   active << { description: item.description, amount_usd: item.selling_usd, amount_idr: item.selling_idr, volume: item.selling_volume, item_type: 'active' }
        # end
        cr.cost_revenue_items.each do |item|
          items << { description: item.description, amount_usd: item.selling_usd, amount_idr: item.selling_idr, volume: item.selling_volume, item_type: item.item_type }
        end

        other = cr.selling_other
        rate = cr.selling_rate
      end

      # si.build_bill_of_lading_invoice( 
      #   is_ai: true,
      #   other: other,
      #   rate: rate,
      #   # bill_of_lading_items_attributes: charges,
      #   bill_of_lading_items_attributes: items,
      #   # volume_items_attributes: volume,
      #   # shipper_items_attributes: shipper,
      #   # carrier_items_attributes: carrier,
      #   # active_items_attributes: active,
      #   # fixed_items_attributes: fixed
      # )
      si.bill_of_lading_invoices.build([ 
        is_ai: true,
        # other: other,
        # rate: rate,
        # bill_of_lading_items_attributes: charges,
        bill_of_lading_items_attributes: items,
        # volume_items_attributes: volume,
        # shipper_items_attributes: shipper,
        # carrier_items_attributes: carrier,
        # active_items_attributes: active,
        # fixed_items_attributes: fixed
      ])
      
    # else
    #   BillOfLading.new
    end
  end

  def initialize_new_payment_invoice
    charges = []
    fixed = []
    active = []
    volume = []
    shipper = []
    carrier = []
    items = []
    other = 0
    rate = 0

    # if si = ShippingInstruction.find(params[:sid])
    si = self
    if si.payment_invoices.blank?
      if si.cost_revenue.blank?
        volume_type = { "LCL" => 0, 
                        "20FT" => 0, 
                        "40FT" => 0, 
                        "40HQ" => 0
                      }
        si.si_containers.each do |item|
          unless item.container.container_type == "Special Equipment" || item.container.container_type == "TYPE"
            volume_type[item.container.container_type] = item.volum
          end
        end

        items << { description: "LCL", volume: volume_type["LCL"].to_f, item_type: 'volume' } unless volume_type["LCL"].to_f == 0
        items << { description: "OF 20\'", volume: volume_type["20FT"].to_f, item_type: 'volume' } unless volume_type["20FT"].to_f == 0
        items << { description: "OF 40\'", volume: volume_type["40FT"].to_f, item_type: 'volume' } unless volume_type["40FT"].to_f == 0
        items << { description: "OF 40HC", volume: volume_type["40HQ"].to_f, item_type: 'volume' } unless volume_type["40HQ"].to_f == 0
        items << { description: "THC 20\'", volume: volume_type["20FT"].to_f, item_type: 'volume' } unless volume_type["20FT"].to_f == 0
        items << { description: "THC 40\'", volume: volume_type["40FT"].to_f, item_type: 'volume' } unless volume_type["40FT"].to_f == 0
        items << { description: "THC 40HC", volume: volume_type["40HQ"].to_f, item_type: 'volume' } unless volume_type["40HQ"].to_f == 0
        
        unless si.shipper.blank?
          unless si.shipper.shipper_items.blank?
            si.shipper.shipper_items.each do |item|
              items << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, volume: 1, item_type: 'shipper' }
            end
          else
            # shipper << { description: 'PEB', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'Fiat PEB', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'COO', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'Trucking', volume: 1, item_type: 'shipper' }
            # shipper << { description: 'Fumigation', volume: 1, item_type: 'shipper' }
          end
        end

        si_carrier = Carrier.find_by(name: si.carrier)
        unless si_carrier.blank?
          unless si_carrier.carrier_items.blank?
            si_carrier.carrier_items.each do |item|
              items << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, volume: 1, item_type: 'carrier' }
            end
          else
            # carrier << { description: 'Doc', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Adm', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Seal', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'AMS/ENS', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Telex', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Switch', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'Certificate', volume: 1, item_type: 'carrier' }
            # carrier << { description: 'SIA', volume: 1, item_type: 'carrier' }
          end
        end

        # fixed << { description: "OTHER", volume: 1, item_type: 'fixed' }
        # fixed << { description: "RATE", volume: 1, item_type: 'fixed' }
        # fixed << { description: "VAT 10%", volume: 1, item_type: 'fixed' }
        # fixed << { description: "VAT 1%", volume: 1, item_type: 'fixed' }
        # fixed << { description: "PPH 23", volume: 1, item_type: 'fixed' }
      else
        cr = si.cost_revenue
        # cr.volume_items.each do |item|
        #   volume << { description: item.description, amount_usd: item.buying_usd, amount_idr: item.buying_idr, volume: item.buying_volume, item_type: 'volume' }
        # end
        # cr.shipper_items.each do |item|
        #   shipper << { description: item.description, amount_usd: item.buying_usd, amount_idr: item.buying_idr, volume: item.buying_volume, item_type: 'shipper' }
        # end
        # cr.carrier_items.each do |item|
        #   carrier << { description: item.description, amount_usd: item.buying_usd, amount_idr: item.buying_idr, volume: item.buying_volume, item_type: 'carrier' }
        # end
        # cr.active_items.each do |item|
        #   active << { description: item.description, amount_usd: item.buying_usd, amount_idr: item.buying_idr, volume: item.buying_volume, item_type: 'active' }
        # end
        cr.cost_revenue_items.each do |item|
          items << { description: item.description, amount_usd: item.buying_usd, amount_idr: item.buying_idr, volume: item.buying_volume, item_type: item.item_type }
        end

        other = cr.buying_other
        rate = cr.buying_rate
      end

      payment_date = si.first_etd_date - 3.days unless si.first_etd_date.blank?
      si.payment_invoices.build([ { 
        payment_date: payment_date, carrier: si.carrier,
        # other: other,
        # rate: rate,
        payment_items_attributes: items,
        # volume_items_attributes: volume,
        # shipper_items_attributes: shipper,
        # carrier_items_attributes: carrier,
        # active_items_attributes: active,
        # fixed_items_attributes: fixed 
        } ])
        # raise si.payment_invoices.first.carrier_items.inspect
      
    # else
    #   BillOfLading.new
    end
  end

  def total_payment_invoices
    # self.payment_invoices.map{|p| p.total_invoice_include_pph_23}.sum(&:to_f).round(2)
    self.payment_invoices.map{|p| p.total_invoice unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def total_bill_of_lading_invoices
    self.bill_of_lading_invoices.map{|p| p.default_total_invoice unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def is_cr_completed?
    self.cost_revenue.blank? ? false : self.cost_revenue.is_completed?
  end

  def is_bl_done?
    self.bill_of_lading.blank? ? false : self.bill_of_lading.delivery_doc
  end

  def is_detail_cost_empty?
    is_true = false
    if self.cost_revenue.blank?
      is_true = true
    else
      count = 0
      self.cost_revenue.cost_revenue_items.each do |item|
        if item.buying_volume.to_f == 0 && item.buying_idr.to_f == 0 && item.buying_usd.to_f == 0 && item.buying_total_after_tax.to_f == 0
          count += 1
        end
      end
      is_true = (self.cost_revenue.cost_revenue_items.count == count) ? true : false
    end
    is_true
  end

  def is_detail_sell_empty?
    is_true = false
    if self.cost_revenue.blank?
      is_true = true
    else
      count = 0
      self.cost_revenue.cost_revenue_items.each do |item|
        if item.selling_volume.to_f == 0 && item.selling_idr.to_f == 0 && item.selling_usd.to_f == 0 && item.selling_total_after_tax.to_f == 0
          count += 1
        end
      end
      is_true = (self.cost_revenue.cost_revenue_items.count == count) ? true : false
    end
    is_true
  end

  def has_outstanding_si?
    has_monitoring = false
    bl = self.bill_of_lading
    
    if bl.blank?
      etd_date = self.first_etd_date
        
      unless etd_date.blank?
        if self.is_open? && self.is_uncanceled?
          has_monitoring = true if etd_date <= DateTime.now.in_time_zone("Jakarta").to_date
        end
      end
    end
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  def has_outstanding_document?
    has_monitoring = false
    bl = self.bill_of_lading

    unless bl.blank?
      if !self.is_bl_done? && !self.is_cr_completed?
        etd_date = self.first_etd_date

        unless etd_date.blank?
          if (etd_date + 1.day) <= DateTime.now.in_time_zone("Jakarta").to_date
            has_monitoring = true
          end
        end
      end
    end
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  def has_outstanding_invoicing?
    has_monitoring = false
    bl = self.bill_of_lading
    
    unless bl.blank?
      unless self.is_cr_completed?
        inv = bl.invoices.uncanceled.count
        dbn = bl.debit_notes.uncanceled.count
        crn = bl.notes.uncanceled.count
        invoice_count = inv + dbn + crn

        if invoice_count > 0
          has_monitoring = false
        else
          vessel = self.vessels.first
          shipper = self.shipper
          
          has_monitoring = true if !vessel.blank? && !shipper.blank?
        end
      end
    end
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  def has_outstanding_payment?
    has_monitoring = false
    bl = self.bill_of_lading

    unless bl.blank?
      etd_date = self.first_etd_date
        
      unless etd_date.blank?
        if self.is_open? && self.is_uncanceled?
          if (etd_date - 2.days) <= DateTime.now.in_time_zone("Jakarta").to_date
            if PaymentReference.where(ibl_ref: ibl_ref).blank?
              ibl_ref = self.ibl_ref
              carrier = self.carrier
          
              has_monitoring = true if !ibl_ref.blank? && !carrier.blank?
            end
          end
        end
      end
    end
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  def has_outstanding_cr?
    has_monitoring = false
    # cr = self.cost_revenue

    # unless cr.blank?
    #   has_monitoring = true if cr.is_open?
    # end

    has_monitoring = true unless self.is_cr_completed?
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  def has_outstanding_tracking?
    has_monitoring = false
    st = self.shipment_tracking

    unless st.blank?
      vessel = self.vessels.first

      unless vessel.blank?
        actual_fu_date = st.fu_date.presence || vessel.etd_date.presence

        unless actual_fu_date.blank?
          # has_monitoring = true if actual_fu_date == DateTime.now.in_time_zone("Jakarta").to_date

          len = (actual_fu_date - DateTime.now.in_time_zone("Jakarta").to_date).to_i
          has_monitoring = true if len == 0
        end
      end
    end
    has_monitoring = true if self.is_connecting?
    has_monitoring = true if self.is_arrived?
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  def has_outstanding_cost_and_sell?
    has_monitoring = false
    cr = self.cost_revenue

    unless cr.blank?
      unless cr.is_completed?
        has_monitoring = true unless self.shipper_company_name == cr.shipper_company_name
        has_monitoring = true unless self.final_destination == cr.final_destination
        has_monitoring = true unless self.volume == cr.volume
        has_monitoring = true unless self.carrier == cr.carrier_name
        has_monitoring = true if cr.default_selling_total_invoice == 0
        has_monitoring = true if cr.default_buying_total_invoice == 0
      end
    else
      has_monitoring = true if self.is_uncanceled?
    end
    has_monitoring = false if self.is_canceled? || self.is_shadow
    has_monitoring
  end

  # def has_list_due_date_invoice?
  #   has_monitoring = false
  #   bl = self.bill_of_lading

  #   unless bl.blank?
  #     has_monitoring = true if bl.is_open?
  #   end
  #   has_monitoring
  #   has_monitoring = false if self.is_canceled? || self.is_shadow
  # end

  def volume_lcl
    str = self.si_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "LCL" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_20ft
    str = self.si_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "20FT" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_40ft
    str = self.si_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "40FT" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_40hq
    str = self.si_containers.order(:container_id).map {|c| (c.container.container_type.upcase == "40HQ" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def volume_type
    str = self.si_containers.map {|c| (c.container.container_type.upcase == "TYPE" ? c.volum : "") }.delete_if{|e| e.squish.length == 0}
    str.first
  end

  def status_cra_text
    str = []
    str.push "Cancel" if self.is_canceled?
    unless self.cost_revenue.blank?
      if self.is_cr_completed?
        str.push "Completed"
      else
        str.push "Open"
      end
    else
      str.push "No Status"
    end
    str.join(" & ")
  end

  def total_invoice_idr
    total = 0
    bl = self.bill_of_lading
    unless bl.blank?
      bl.invoices.each do |inv|
        total += inv.grand_total.to_f if inv.is_uncanceled? && inv.currency_code == "IDR"
      end
    end
    total.round(2)
  end

  def total_invoice_usd
    total = 0
    bl = self.bill_of_lading
    unless bl.blank?
      bl.invoices.each do |inv|
        total += inv.grand_total.to_f if inv.is_uncanceled? && inv.currency_code == "USD"
      end
    end
    total.round(2)
  end

  private
  def set_default_attributes
    self.si_date = Time.now if self.si_date.to_s.empty?
    self.country_of_origin = "INDONESIA" if self.country_of_origin.to_s.empty?
    self.notify_party = "SAME AS CONSIGNEE" if self.notify_party.to_s.empty?
    self.place_of_receipt = "JAKARTA" if self.place_of_receipt.to_s.empty?
    self.port_of_loading = "TG. PRIOK, JAKARTA, INDONESIA" if self.port_of_loading.to_s.empty?
    self.freight = "FREIGHT PREPAID \nFCL - FCL" if self.freight.to_s.empty?
    self.special_instructions = "DO NOT ROLL OVER THIS CARGO\nPLEASE ARRANGE 14 DAYS FREE TIME DETENTION + 14 DAYS FREE TIME DEMURRAGE\nPLEASE RELEASE CONTAINER GRADE A" if self.special_instructions.to_s.empty?
  end

  def check_associations
    self.si_containers.each do |container|
      unless container.container.container_type.upcase == "TYPE"
        container.mark_for_destruction if container.volum.to_f <= 0
      else
        container.mark_for_destruction if container.volum.blank?
      end
    end
  end

  def generate_workers
    # unless is_shadow?
    #   unless is_cancel?
        SiMonitoringWorker.perform_async(id)
        PaymentMonitoringWorker.perform_async(id)
        CrMonitoringWorker.perform_async(id)
        ShipmentMonitoringWorker.perform_async(id)

        InvoiceMonitoringWorker.perform_async(id)
        DocumentMonitoringWorker.perform_async(id)
        SellCostMonitoringWorker.perform_async(id)

        BlMonitoringWorker.perform_async(id)
        # logger.info "Perform Async SI #{ibl_ref}"
    #   else
    #     SiMonitoring.where(shipping_instruction_id: id).destroy_all
    #     PaymentMonitoring.where(shipping_instruction_id: id).destroy_all
    #     CrMonitoring.where(shipping_instruction_id: id).destroy_all
    #     ShipmentMonitoring.where(shipping_instruction_id: id).destroy_all

    #     InvoiceMonitoring.where(shipping_instruction_id: id).destroy_all
    #     DocumentMonitoring.where(shipping_instruction_id: id).destroy_all
    #     SellCostMonitoring.where(shipping_instruction_id: id).destroy_all

    #     BlMonitoring.where(shipping_instruction_id: id).destroy_all
    #     logger.info "Destroy Monitoring SI #{ibl_ref}"
    #   end
    # end
  end
end
