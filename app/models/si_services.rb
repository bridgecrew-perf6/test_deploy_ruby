class SIServices
  def initialize(shipping_instruction)
    @shipping_instruction = shipping_instruction
  end

  def self.get_list_si(params)
    @shipping_instructions = ShippingInstruction.all
    begin
      case params[:filter_si_by]
      when "monthly"
        date = Date.parse(params[:filter_si_monthly])
        @shipping_instructions = @shipping_instructions.joins("LEFT OUTER JOIN vessels VS ON (VS.id = (SELECT SV.id FROM vessels SV WHERE SV.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
        .where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      when "yearly"
        year = Constant.years_range.include?(params[:filter_si_yearly].to_i) ? params[:filter_si_yearly] : Date.today.year
        @shipping_instructions = @shipping_instructions.where("si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
      end
    end

    @shipping_instructions
  end

  def self.get_shipments_tracking(params)
    @shipments = ShipmentTracking.all
    begin
      case params[:filter_shipments_by]
      when "monthly"
        date = Date.parse(params[:filter_shipments_monthly])
        @shipments = @shipments
        .joins(:shipping_instruction)
        .joins("LEFT OUTER JOIN vessels V ON (V.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
        .where("V.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      when "yearly"
        year = Constant.years_range.include?(params[:filter_shipments_yearly].to_i) ? params[:filter_shipments_yearly] : Date.today.year
        @shipments = @shipments
        .joins(:shipping_instruction)
        .where("shipping_instructions.si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
      end
    rescue
      # Ignored
    end

    @shipments
  end

  def self.get_cost_revenues(params)
    begin
      case params[:filter_cra_by]
      when "monthly"
        date = Date.parse(params[:filter_cra_monthly])
        @cost_revenues = CostRevenue.includes(:cost_revenue_items).joins(:shipping_instruction,
                "LEFT OUTER JOIN vessels ON (vessels.id = (SELECT DV.id FROM vessels DV WHERE DV.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
        .where("vessels.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        .order("shipping_instructions.si_no ASC")
      when "yearly"
        year = Constant.years_range.include?(params[:filter_cra_yearly].to_i) ? params[:filter_cra_yearly] : Date.today.year
        @cost_revenues = CostRevenue.includes(:cost_revenue_items).joins(:shipping_instruction)
        .where("shipping_instructions.si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
        .order("shipping_instructions.si_no ASC")
      else
        raise
      end
      # if params[:filter_cra_monthly]
      #   date = Date.parse(params[:filter_cra_monthly])
      #   #@cost_revenues = CostRevenue.includes({shipping_instruction: [:vessels]}, :cost_revenue_items)
      #   #.where(vessels: {etd_date: date.at_beginning_of_month..date.end_of_month})
      #   #.references({shipping_instruction: [:vessels]}, :cost_revenue_items)
      #   @cost_revenues = CostRevenue.includes(:cost_revenue_items).joins(:shipping_instruction,
      #           "LEFT OUTER JOIN vessels ON (vessels.id = (SELECT DV.id FROM vessels DV WHERE DV.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
      #   .where("vessels.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      #   .order("shipping_instructions.si_no ASC")
      # else
      #   raise
      # end
    rescue
      @cost_revenues = CostRevenue.includes(:cost_revenue_items)
    end
  end

  def cancel!
    @shipping_instruction.class.transaction do
      cancel_shipping_instruction!(true)
      cancel_bill_of_lading!(true)
      cancel_invoices!(true)
      cancel_debit_notes!(true)
      cancel_notes!(true)
    end
  end

  def uncancel!
    @shipping_instruction.class.transaction do
      cancel_shipping_instruction!(false)
      cancel_bill_of_lading!(false)
      cancel_invoices!(false)
      cancel_debit_notes!(false)
      cancel_notes!(false)
    end
  end

  def description_exists(the_data, text)
    the_data.each_with_index do |data, index|
      return index if data[:description] == text
    end
    false
  end

  # def get_cost_revenues_data
  #   payments = PaymentReference.includes(:payment).references(:payment).where(ibl_ref: @shipping_instruction.si_no)
  #   payments = payments.group_by { |p| p.payment.payment_type }

  #   # invoices = (
  #   # Invoice.includes(:invoice_details).references(:invoice_details).where(ibl_no: @shipping_instruction.si_no) +
  #   #   DebitNote.includes(:debit_note_details).references(:debit_note_details).where(ibl_no: @shipping_instruction.si_no) +
  #   #   Note.includes(:note_details).references(:note_details).where(ibl_no: @shipping_instruction.si_no)
  #   # )

  #   # Revisi 22 December 2015
  #   invoices = (
  #   Invoice.includes(:invoice_details).references(:invoice_details).where(ibl_no: @shipping_instruction.si_no, is_cancel: 0) +
  #     DebitNote.includes(:debit_note_details).references(:debit_note_details).where(ibl_no: @shipping_instruction.si_no, is_cancel: 0) +
  #     Note.includes(:note_details).references(:note_details).where(ibl_no: @shipping_instruction.si_no, is_cancel: 0)
  #   )

  #   data = Array.new

  #   if payments.any?
  #     data.push(
  #       {
  #         description: "FREIGHT",
  #         selling: {
  #           usd: 0,
  #           idr: 0
  #         },
  #         buying: {
  #           usd: payments["USD"].try(:map) { |p| p.amount.gsub(",", "").to_d }.try(:sum) || 0,
  #           idr: payments["IDR"].try(:map) { |p| p.amount.gsub(",", "").to_d }.try(:sum) || 0
  #         }
  #       }
  #     )
  #   end

  #   invoices.try(:each) do |invoice|
  #     details = (invoice.try(:invoice_details) || invoice.try(:debit_note_details) || invoice.try(:note_details))
  #     details.each do |detail|
  #       if index = self.description_exists(data, detail.description)
  #         data[index][:selling][invoice.currency_code.downcase.to_sym] += detail.amount * detail.volume
  #       else
  #         data.push(
  #           {
  #             description: detail.description,
  #             selling: {
  #               usd: 0,
  #               idr: 0
  #             },
  #             buying: {
  #               usd: 0,
  #               idr: 0
  #             }
  #           }
  #         )
  #         data[data.length - 1][:selling][invoice.currency_code.downcase.to_sym] = detail.amount * detail.volume
  #       end
  #     end
  #   end

  #   data.any? ? data : ""
  # end

  # Revisi 1 Dec 2015,             
  def get_shipping_instruction_data
    # data = Array.new
    si = @shipping_instruction
    data = {  shipper_id: si.shipper_id, 
              consignee_id: si.consignee_id, 
              shipper_name: si.shipper_name, 
              consignee_name: si.consignee_name, 
              notify_party: si.notify_party, 
              country_of_origin: si.country_of_origin, 
              carrier: si.carrier, 
              pic: si.pic, 
              feeder_vessel: si.feeder_vessel, 
              connection_vessel: si.connection_vessel, 
              place_of_receipt: si.place_of_receipt, 
              port_of_loading: si.port_of_loading, 
              port_of_transhipment: si.port_of_transhipment, 
              port_of_discharge: si.port_of_discharge, 
              final_destination: si.final_destination, 
              no_of_obl: si.no_of_obl, 
              si_date: si.si_date, 
              marks_no: si.marks_no, 
              description_packages: si.description_packages, 
              gw: si.gw, 
              nw: si.nw, 
              measurement: si.measurement, 
              dimension: si.dimension, 
              freight: si.freight, 
              freight_details: si.freight_details, 
              special_instructions: si.special_instructions, 
              container_no: si.container_no, 
              container_no_2: si.container_no_2, 
              peb_no: si.peb_no, 
              inst_date: si.inst_date, 
              kpbc: si.kpbc, 
              hs_code: si.hs_code,
              # , create_by: si.create_by,
              # , update_by: si.update_by, 
              shipper_reference: si.shipper_reference, 
              status: si.status, 
              order_type: si.order_type, 
              booking_no: si.booking_no, 
              master_bl_no: si.master_bl_no,
              # created_at: si.created_at, 
              # updated_at: si.updated_at,
              trade: si.trade, 
              handle_by: si.handle_by, 
              order_type_details: si.order_type_details,
              vessels: 
                si.vessels.map.each do |vessel|
                  { 
                    vessel_name: vessel.vessel_name, 
                    etd_no: vessel.etd_no, 
                    etd_date: vessel.etd_date, 
                    eta_no: vessel.eta_no, 
                    eta_date: vessel.eta_date
                  }
                end ,
              si_containers: 
                si.si_containers.map.each do |si_container|
                  { 
                    container_id: si_container.container_id,
                    volum: si_container.volum
                  }
                end
              
    }
    !data.blank? ? data : ""
  end

  def get_cost_revenue_items_data
    data = []
    cost_revenue = @shipping_instruction.cost_revenue
    unless cost_revenue.blank?
      cost_revenue.cost_revenue_items.each do |item|
        data << {  description: item.description, 
                    selling_usd: item.selling_usd, 
                    selling_idr: item.selling_idr, 
                    buying_usd: item.buying_usd, 
                    buying_idr: item.buying_idr, 
                    selling_volume: item.selling_volume, 
                    buying_volume: item.buying_volume, 
                    selling_total: item.selling_total,
                    buying_total: item.buying_total,
                    selling_total_after_tax: item.selling_total_after_tax,
                    buying_total_after_tax: item.buying_total_after_tax,
                    item_type: item.item_type, 
                    item_order: item.item_order
                  }
      end  
    end

    data.any? ? data : ""
  end

  def get_cost_revenue_data
    data = []
    cost_revenue = @shipping_instruction.cost_revenue
    if cost_revenue.blank?
      # No data to be imported
      data = {success: false, message: "Cost Revenue Not Listed"}
    else
      data = begin
        items = []
        cost_revenue.cost_revenue_items.each do |item|
          items << {  description: item.description, 
                      selling_usd: item.selling_usd, 
                      selling_idr: item.selling_idr, 
                      buying_usd: item.buying_usd, 
                      buying_idr: item.buying_idr, 
                      selling_volume: item.selling_volume, 
                      buying_volume: item.buying_volume, 
                      selling_total: item.selling_total,
                      buying_total: item.buying_total,
                      selling_total_after_tax: item.selling_total_after_tax,
                      buying_total_after_tax: item.buying_total_after_tax,
                      item_type: item.item_type, 
                      item_order: item.item_order
                    }
        end

        { success: true,  etd_date: cost_revenue.etd_date,
                          carrier: cost_revenue.carrier,
                          
                          notes: cost_revenue.notes,

                          selling_other: cost_revenue.selling_other, 
                          selling_rate: cost_revenue.selling_rate, 
                          selling_vat_10: cost_revenue.selling_vat_10, 
                          selling_vat_1: cost_revenue.selling_vat_1, 
                          selling_pph_23: cost_revenue.selling_pph_23,
                          selling_total_invoice: cost_revenue.selling_total_invoice,
                          
                          buying_other: cost_revenue.buying_other, 
                          buying_rate: cost_revenue.buying_rate, 
                          buying_vat_10: cost_revenue.buying_vat_10, 
                          buying_vat_1: cost_revenue.buying_vat_1, 
                          buying_pph_23: cost_revenue.buying_pph_23,
                          buying_total_invoice: cost_revenue.buying_total_invoice,
                          
                          adda: cost_revenue.adda,
                          addb: cost_revenue.addb,
                          addc: cost_revenue.addc,
                          addt: cost_revenue.addt,
                          gpt: cost_revenue.gpt,
                          npt: cost_revenue.npt,

                          items: items }
      end
    end

    data
  end

  def get_sell_comparison_data
    # invoice = @shipping_instruction.bill_of_lading_invoice
    # if invoice.blank?
    #   data = {success: false, message: "Calculate Invoice Not Listed"}
    # else
    #   data = begin
    #     items = []
    #     invoice.bill_of_lading_items.each do |item|
    #       items << { 
    #         description: item.description, 
    #         amount_usd: item.amount_usd, 
    #         amount_idr: item.amount_idr, 
    #         volume: item.volume, 
    #         total: item.total,
    #         total_after_tax: item.total_after_tax,
    #         item_type: item.item_type, 
    #         item_order: item.item_order
    #       }
    #     end

    #     { success: true, other: invoice.other, 
    #                       rate: invoice.rate, 
    #                       vat_10: invoice.vat_10, 
    #                       vat_1: invoice.vat_1, 
    #                       pph_23: invoice.pph_23,
    #                       total_invoice: invoice.total_invoice,
    #                       items: items }
    #   end
    # end

    invoices = @shipping_instruction.bill_of_lading_invoices
    if invoices.blank?
      data = {success: false, message: "Calculate Invoice Not Listed"}
    else
      data = begin
        items = []
        invoices.each do |invoice|
          invoice.bill_of_lading_items.each do |item|
            items << { 
              description: item.description, 
              amount_usd: item.amount_usd, 
              amount_idr: item.amount_idr, 
              volume: item.volume, 
              total: item.total,
              total_after_tax: item.total_after_tax,
              item_type: item.item_type, 
              item_order: item.item_order
            }
          end
        end

        { success: true,  other: invoices.map{|p| p.other}.sum(&:to_f), 
                          rate: invoices.first.rate, 
                          vat_10: invoices.map{|p| p.vat_10}.sum(&:to_f), 
                          vat_1: invoices.map{|p| p.vat_1}.sum(&:to_f), 
                          pph_23: invoices.map{|p| p.pph_23}.sum(&:to_f),
                          total_invoice: invoices.map{|p| p.total_invoice}.sum(&:to_f),
                          items: items }
      end
    end
    data
  end

  # def get_cost_comparison_data
  #   invoices = @shipping_instruction.payment_invoices
  #   if invoices.blank?
  #     data = {success: false, message: "Calculate Invoice BL Not Listed"}
  #   else
  #     data = begin
  #       diff = []
  #       invoice1 = invoices.first
  #       items1 = []
  #       invoice1.payment_items.each do |item|
  #         items1 << { 
  #           description: item.description, 
  #           amount_usd: item.amount_usd, 
  #           amount_idr: item.amount_idr, 
  #           volume: item.volume, 
  #           total: item.total,
  #           total_after_tax: item.total_after_tax,
  #           item_type: item.item_type, 
  #           item_order: item.item_order
  #         }
  #       end
        
  #       diff += items1

  #       invoices.each do |invoice|
  #         items2 = []
  #         invoice.payment_items.each do |item|
  #           items2 << { 
  #             description: item.description, 
  #             amount_usd: item.amount_usd, 
  #             amount_idr: item.amount_idr, 
  #             volume: item.volume, 
  #             total: item.total,
  #             total_after_tax: item.total_after_tax,
  #             item_type: item.item_type, 
  #             item_order: item.item_order
  #           }
  #         end
  #         items1.each do |item1|
  #           items2.delete_if { |key, value| key.to_s == item1.to_s } unless items2.blank?
  #         end

  #         diff += items2
          
  #       end

  #       { success: true, 
  #                         # other: invoice.other, 
  #                         # rate: invoice.rate, 
  #                         # vat_10: invoice.vat_10, 
  #                         # vat_1: invoice.vat_1, 
  #                         # pph_23: invoice.pph_23,
  #                         # total_invoice: invoice.total_invoice,
  #                         items: diff }
  #     end
  #   end

  #   data
  # end
  def get_cost_comparison_data
    invoices = @shipping_instruction.payment_invoices
    if invoices.blank?
      data = {success: false, message: "Payment Plan Not Listed"}
    else
      data = begin
        items = []
        invoices.each do |invoice|
          invoice.payment_items.each do |item|
            items << { 
              description: item.description, 
              amount_usd: item.amount_usd, 
              amount_idr: item.amount_idr, 
              volume: item.volume, 
              total: item.total,
              total_after_tax: item.total_after_tax,
              item_type: item.item_type, 
              item_order: item.item_order
            }
          end
        end

        { success: true,  other: invoices.map{|p| p.other}.sum(&:to_f), 
                          rate: invoices.first.rate, 
                          vat_10: invoices.map{|p| p.vat_10}.sum(&:to_f), 
                          vat_1: invoices.map{|p| p.vat_1}.sum(&:to_f), 
                          pph_23: invoices.map{|p| p.pph_23}.sum(&:to_f),
                          total_invoice: invoices.map{|p| p.total_invoice}.sum(&:to_f),
                          items: items }
      end
    end

    data
  end

  private
  def cancel_shipping_instruction!(value)
    @shipping_instruction.update_attribute(:is_cancel, value)
  end

  def cancel_bill_of_lading!(value)
    @shipping_instruction.bill_of_lading.update_attribute(:is_cancel, value) if @shipping_instruction.bill_of_lading
  end

  def cancel_invoices!(value)
    @shipping_instruction.bill_of_lading.invoices.each { |invoice|
      invoice.update_attribute(:is_cancel, value) } if @shipping_instruction.bill_of_lading
  end

  def cancel_debit_notes!(value)
    @shipping_instruction.bill_of_lading.debit_notes.each { |debit_note|
      debit_note.update_attribute(:is_cancel, value) } if @shipping_instruction.bill_of_lading
  end

  def cancel_notes!(value)
    @shipping_instruction.bill_of_lading.notes.each { |note|
      note.update_attribute(:is_cancel, value) } if @shipping_instruction.bill_of_lading
  end
end
