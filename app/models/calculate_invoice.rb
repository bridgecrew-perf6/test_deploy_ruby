class CalculateInvoice < ActiveRecord::Base
  self.table_name = "shipping_instructions"
  self.primary_key = "id"

  include UpcaseAttributes


  with_options dependent: :destroy do |assoc|
    assoc.has_many :bill_of_lading_invoices, foreign_key: 'shipping_instruction_id'
  end

  with_options allow_destroy: true do |nest_attr|
    nest_attr.accepts_nested_attributes_for :bill_of_lading_invoices, :reject_if => lambda { |a| a[:is_ai].blank? && a[:is_gi].blank? }
  end

  validate :check_bill_of_lading_invoices_rate

  def check_bill_of_lading_invoices_rate
    valid = true
    self.bill_of_lading_invoices.each do |value|
      unless value.marked_for_destruction?
        valid = false if value.rate.to_f == 0
      end
    end
    errors.add(:base, "Please fill all rate. Thanks") unless valid
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
    # si = self
    si = ShippingInstruction.find(self.id)
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
      self.bill_of_lading_invoices.build([ 
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

  def total_bill_of_lading_invoices
    self.bill_of_lading_invoices.map{|p| p.default_total_invoice unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end
end
