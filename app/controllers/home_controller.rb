class HomeController < ApplicationController
  # before_action :authorize, only: [:index, :control_center,
  #                                  :outstanding_bonshipment,
  #                                  :search_outstanding_bonshipment, :report_tracking,
  #                                  :list_tracking, :list_inv_dbn, :create_new_invoice]
  before_action :authorize, only: [:index, :backup, :db_backup, :db_restore]
  before_action :is_admin, only: [:control_center, :search_control_center, :backup, :db_backup, :db_restore]

  def index
    # redirect_to login_url and return if current_user.nil?
    # year = params[:year].presence || Time.now.year.to_s
    # si_monitorings = SiMonitoring.where('si_no LIKE ?', "IBL#{year[2..3]}%").order(shipment_date: :desc, si_no: :desc)
    # bl_not_invoiced_monitorings = BlMonitoring.where('hbl_no LIKE ?', "IBL#{year[2..3]}%").order(shipment_date: :desc, hbl_no: :desc).not_invoiced
    # payment_monitorings = PaymentMonitoring.where('hbl_no LIKE ?', "IBL#{year[2..3]}%").order(shipment_date: :desc, hbl_no: :desc)
    # cr_monitorings = CrMonitoring.where('hbl_no LIKE ?', "IBL#{year[2..3]}%").order(shipment_date: :desc, hbl_no: :desc)
    # shipment_monitorings = ShipmentMonitoring.where('hbl_no LIKE ?', "IBL#{year[2..3]}%").order(shipment_date: :desc, hbl_no: :desc)

    # @si_monitorings_count = si_monitorings.count
    # @si_monitorings = si_monitorings.group_by { |t| t.shipment_date.try(:at_beginning_of_month) }
    # @si_monitorings.each { |m, g| g.sort! { |x, y| y.si_no <=> x.si_no } }

    # @grouped_not_invoiced_count = bl_not_invoiced_monitorings.count
    # @grouped_not_invoiced = bl_not_invoiced_monitorings.group_by { |t| t.shipment_date.try(:at_beginning_of_month) }
    # @grouped_not_invoiced.each { |m, g| g.sort! { |x, y| y.hbl_no <=> x.hbl_no } }

    # # @grouped_not_closed_count = bl_not_closed_monitorings.count
    # # @grouped_not_closed = bl_not_closed_monitorings.group_by { |t| t.shipment_date.try(:at_beginning_of_month) }

    # @grouped_payments_count = payment_monitorings.count
    # @grouped_payments = payment_monitorings.group_by { |t| t.shipment_date.try(:at_beginning_of_month) }
    # @grouped_payments.each { |m, g| g.sort! { |x, y| y.hbl_no <=> x.hbl_no } }

    # @grouped_cr_monitorings_count = cr_monitorings.count
    # @grouped_cr_monitorings = cr_monitorings.group_by { |t| t.shipment_date.try(:at_beginning_of_month) }
    # @grouped_cr_monitorings.each { |m, g| g.sort! { |x, y| y.hbl_no <=> x.hbl_no } }

    # # @commision_monitorings = CommisionMonitoring.where('hbl_no LIKE ?', "IBL#{year[2..3]}%").order(hbl_no: :desc)
    # @grouped_shipments_count = shipment_monitorings.count
    # @grouped_shipments = shipment_monitorings.group_by { |t| t.shipment_date.try(:at_beginning_of_month) }
    # @grouped_shipments.each { |m, g| g.sort! { |x, y| y.hbl_no <=> x.hbl_no } }

    # document_monitorings = DocumentMonitoring.includes(:shipping_instruction, :bill_of_lading).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    # @grouped_document_count = document_monitorings.count
    # @grouped_documents = document_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    # @grouped_documents.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    # sell_cost_monitorings = SellCostMonitoring.includes(:cost_revenue).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    # @grouped_sell_cost_count = sell_cost_monitorings.count
    # @grouped_sell_costs = sell_cost_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    # @grouped_sell_costs.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    # invoice_monitorings = InvoiceMonitoring.includes(:invoice, :debit_note, :note).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    # @grouped_invoice_count = invoice_monitorings.count
    # @grouped_invoices = invoice_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    # @grouped_invoices.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }



    redirect_to login_url and return if current_user.nil?
    year = params[:year].presence || Time.now.year.to_s
    si_monitorings = SiMonitoring.where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    document_monitorings = DocumentMonitoring.where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    shipment_monitorings = ShipmentMonitoring.includes(:shipment_tracking).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    bl_not_invoiced_monitorings = BlMonitoring.includes(:bill_of_lading).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    payment_monitorings = PaymentMonitoring.includes(:shipping_instruction).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    # invoice_monitorings = InvoiceMonitoring.includes(:invoice, :debit_note, :note).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    invoice_monitorings = InvoiceMonitoring.where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    sell_cost_monitorings = SellCostMonitoring.includes(:cost_revenue).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    cr_monitorings = CrMonitoring.includes(:cost_revenue).where('ibl_ref LIKE ?', "IBL#{year[2..3]}%").order(etd_date: :desc, ibl_ref: :desc)
    
    @si_monitorings_count = si_monitorings.count
    @si_monitorings = si_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @si_monitorings.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_document_count = document_monitorings.count
    @grouped_documents = document_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_documents.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_shipments_count = shipment_monitorings.count
    @grouped_shipments = shipment_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_shipments.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_not_invoiced_count = bl_not_invoiced_monitorings.count
    @grouped_not_invoiced = bl_not_invoiced_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_not_invoiced.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_payments_count = payment_monitorings.count
    @grouped_payments = payment_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_payments.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_invoice_count = invoice_monitorings.count
    @grouped_invoices = invoice_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_invoices.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_sell_cost_count = sell_cost_monitorings.count
    @grouped_sell_costs = sell_cost_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_sell_costs.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }

    @grouped_cr_monitorings_count = cr_monitorings.count
    @grouped_cr_monitorings = cr_monitorings.group_by { |t| t.etd_date.try(:at_beginning_of_month) }
    @grouped_cr_monitorings.each { |m, g| g.sort! { |x, y| y.ibl_ref <=> x.ibl_ref } }
  end

  def control_center

  end

  def search_control_center
    @invoices = InvoiceServices.find_with_vessels(params).first(10)
    @shipping_instructions = InvoiceServices.get_shipping_instructions(@invoices, params)

    render "control_center"

    # invoices_sql = "SELECT I.id, I.bill_of_lading_id, I.no_invoice, I.invoice_date, I.due_date, I.currency_code, I.status_payment, I.notes_payment, I.to_shipper, I.date_of_payment, I.is_cancel, I.customer_ori, 'INV' as tipe FROM invoices I " +
    #   "LEFT OUTER JOIN bill_of_ladings IBL ON (IBL.id = I.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions ISI ON (ISI.id = IBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels IVS ON (IVS.id = (SELECT IV.id FROM vessels IV WHERE IV.shipping_instruction_id = ISI.id LIMIT 1)) "
    # debit_notes_sql = "SELECT D.id, D.bill_of_lading_id, D.no_dbn as no_invoice, D.dbn_date as invoice_date, D.due_date, D.currency_code, D.status_payment, D.notes_payment, D.to_shipper, D.date_of_payment, D.is_cancel, D.customer_ori, 'DBN' as tipe FROM debit_notes D " +
    #   "LEFT OUTER JOIN bill_of_ladings DBL ON (DBL.id = D.bill_of_lading_id) "  +
    #   "LEFT OUTER JOIN shipping_instructions DSI ON (DSI.id = DBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels DVS ON (DVS.id = (SELECT DV.id FROM vessels DV WHERE DV.shipping_instruction_id = DSI.id LIMIT 1)) "
    # notes_sql = "SELECT N.id, N.bill_of_lading_id, N.no_note as no_invoice, N.note_date as invoice_date, N.due_date, N.currency_code, N.status_payment, N.notes_payment, N.to_shipper, N.date_of_payment, N.is_cancel, N.customer_ori, 'NOTE' as tipe FROM notes N " +
    #   "LEFT OUTER JOIN bill_of_ladings NBL ON (NBL.id = N.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions NSI ON (NSI.id = NBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels NVS ON (NVS.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = NSI.id LIMIT 1)) "
    # invoices_sql = "SELECT I.id, I.bill_of_lading_id, I.no_invoice, I.invoice_date, I.due_date, I.currency_code, I.status, I.notes_payment, I.to_shipper, I.date_of_payment, I.is_cancel, 'INV' as tipe FROM invoices I " +
    #   "LEFT OUTER JOIN bill_of_ladings IBL ON (IBL.id = I.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions ISI ON (ISI.id = IBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels IVS ON (ISI.id = IVS.shipping_instruction_id) "
    # debit_notes_sql = "SELECT D.id, D.bill_of_lading_id, D.no_dbn as no_invoice, D.dbn_date as invoice_date, D.due_date, D.currency_code, D.status, D.notes_payment, D.to_shipper, D.date_of_payment, D.is_cancel, 'DBN' as tipe FROM debit_notes D " +
    #   "LEFT OUTER JOIN bill_of_ladings DBL ON (DBL.id = D.bill_of_lading_id) "  +
    #   "LEFT OUTER JOIN shipping_instructions DSI ON (DSI.id = DBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels DVS ON (DSI.id = DVS.shipping_instruction_id) "
    # notes_sql = "SELECT N.id, N.bill_of_lading_id, N.no_note as no_invoice, N.note_date as invoice_date, N.due_date, N.currency_code, N.status, N.notes_payment, N.to_shipper, N.date_of_payment, N.is_cancel, 'NOTE' as tipe FROM notes N " +
    #   "LEFT OUTER JOIN bill_of_ladings NBL ON (NBL.id = N.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions NSI ON (NSI.id = NBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels NVS ON (NSI.id = NVS.shipping_instruction_id) "

    # if ((params.has_key?(:shipper_id) && !params[:shipper_id].blank?) && params.has_key?(:date_filter))
    #   begin
    #     date = Date.parse(params[:date_filter])
    #     # invoices_sql += "WHERE IBL.shipper_id = #{params[:shipper_id]} && I.invoice_date BETWEEN '#{params[:date_from].to_time.strftime('%Y-%m-%d')}' AND '#{params[:date_to].to_time.strftime('%Y-%m-%d')}' "
    #     # debit_notes_sql += "WHERE DBL.shipping_instruction_ider_id = #{params[:shipper_id]} && D.dbn_date BETWEEN '#{params[:date_from].to_time.strftime('%Y-%m-%d')}' AND '#{params[:date_to].to_time.strftime('%Y-%m-%d')}' "
    #     # notes_sql += "WHERE NBL.shipper_id = #{params[:shipper_id]} && N.note_date BETWEEN '#{params[:date_from].to_time.strftime('%Y-%m-%d')}' AND '#{params[:date_to].to_time.strftime('%Y-%m-%d')}' "
    #     invoices_sql += "WHERE ISI.shipper_id = #{params[:shipper_id]} AND (IVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #     debit_notes_sql += "WHERE DSI.shipper_id = #{params[:shipper_id]} AND (DVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #     notes_sql += "WHERE NSI.shipper_id = #{params[:shipper_id]} AND (NVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #   end
    # elsif (params.has_key?(:date_filter))
    #   begin
    #     date = Date.parse(params[:date_filter])
    #     # invoices_sql += "WHERE I.invoice_date BETWEEN '#{params[:date_from].to_time.strftime('%Y-%m-%d')}' AND '#{params[:date_to].to_time.strftime('%Y-%m-%d')}' "
    #     # debit_notes_sql += "WHERE D.dbn_date BETWEEN '#{params[:date_from].to_time.strftime('%Y-%m-%d')}' AND '#{params[:date_to].to_time.strftime('%Y-%m-%d')}' "
    #     # notes_sql += "WHERE N.note_date BETWEEN '#{params[:date_from].to_time.strftime('%Y-%m-%d')}' AND '#{params[:date_to].to_time.strftime('%Y-%m-%d')}' "
    #     invoices_sql += "WHERE (IVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #     debit_notes_sql += "WHERE (DVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #     notes_sql += "WHERE (NVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #   end
    # end

    # if params[:status].to_i < 2
    #   invoices_sql += "AND I.status_payment = #{params[:status]} "
    #   debit_notes_sql += "AND D.status_payment = #{params[:status]} "
    #   notes_sql += "AND N.status_payment = #{params[:status]} "
    # end

    # invoices_sql += "AND I.is_cancel = 0 "
    # debit_notes_sql += "AND D.is_cancel = 0 "
    # notes_sql += "AND N.is_cancel = 0 "

    # invoices_sql += "GROUP BY IVS.shipping_instruction_id "
    # debit_notes_sql += "GROUP BY DVS.shipping_instruction_id "
    # notes_sql += "GROUP BY NVS.shipping_instruction_id "

    # if ((params.has_key?(:shipper_id) && !params[:shipper_id].blank?) && params.has_key?(:date_from) && params.has_key?(:date_to))
    # @invoices = Invoice.includes(:bill_of_lading)
    # .where(invoice_date: params[:date_from].to_date..params[:date_to].to_date, bill_of_ladings: {shipper_id: params[:shipper_id]})
    # .references(:bill_of_ladings).order("bill_of_ladings.bl_number ASC")
    # @debit_notes = DebitNote.includes(:bill_of_lading)
    # .where(dbn_date: params[:date_from].to_date..params[:date_to].to_date, bill_of_ladings: {shipper_id: params[:shipper_id]})
    # .references(:bill_of_ladings).order("bill_of_ladings.bl_number ASC")
    # elsif (params.has_key?(:date_from) && params.has_key?(:date_to))
    # @invoices = Invoice.includes(:bill_of_lading).where(invoice_date: params[:date_from].to_date..params[:date_to].to_date).references(:bill_of_ladings).order("bill_of_ladings.bl_number ASC")
    # @debit_notes = DebitNote.includes(:bill_of_lading).where(dbn_date: params[:date_from].to_date..params[:date_to].to_date).references(:bill_of_ladings).order("bill_of_ladings.bl_number ASC")
    # end

    # sql = "#{invoices_sql} UNION ALL #{debit_notes_sql} UNION ALL #{notes_sql} ORDER BY bill_of_lading_id ASC, no_invoice DESC"
    # @invoices = Invoice.find_by_sql(sql)

    # begin
    #   if params[:status].to_i == 2
    #     if @invoices.any?
    #     available_si = @invoices.map { |e| e.bill_of_lading.shipping_instruction.id }.join(", ")
    #     si_query = "SELECT SI.* FROM shipping_instructions SI " +
    #       "LEFT OUTER JOIN vessels ON (vessels.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = SI.id LIMIT 1)) " +
    #       "WHERE SI.id NOT IN (#{available_si}) AND (vessels.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND is_shadow = 0 AND is_cancel = 0 "
    #     else
    #     si_query = "SELECT SI.* FROM shipping_instructions SI " +
    #       "LEFT OUTER JOIN vessels ON (vessels.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = SI.id LIMIT 1)) " +
    #       "WHERE (vessels.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND is_shadow = 0 AND is_cancel = 0 "
    #     end
    #     if (params.has_key?(:shipper_id) && !params[:shipper_id].blank?)
    #       si_query += "AND SI.shipper_id = #{params[:shipper_id]} "
    #     end
    #     @shipping_instructions = ShippingInstruction.find_by_sql(si_query)
    #   else
    #     raise
    #   end
    # rescue => e
    #   @shipping_instructions = ShippingInstruction.none
    # end
    #
    # render "control_center"
  end

  def outstanding_bonshipment

  end

  def search_outstanding_bonshipment
    # revenue = []
    # CostRevenue.all.each do |c|
    #  c.payment_no.split(",").each do |no|
    #    revenue.push(no)
    #  end
    # end
    if (params.has_key?(:shipper_id) && !params[:shipper_id].blank?) && params.has_key?(:date_from) && params.has_key?(:date_to)
      @invoices = Invoice.includes(:bill_of_lading)
      .where(invoice_date: params[:date_from].to_date..params[:date_to].to_date, bill_of_ladings: {shipper_id: params[:shipper_id]})
      .where.not(bill_of_ladings: {shipping_instruction_id: CostRevenue.all.map { |e| e.shipping_instruction_id }})
      .references(:bill_of_ladings)
    elsif params.has_key?(:date_from) && params.has_key?(:date_to)
      @invoices = Invoice.includes(:bill_of_lading)
      .where(invoice_date: params[:date_from].to_date..params[:date_to].to_date)
      .where.not(bill_of_ladings: {shipping_instruction_id: CostRevenue.all.map { |e| e.shipping_instruction_id }})
      .references(:bill_of_ladings)
    end
    render "outstanding_bonshipment"
  end

  def report_tracking
    # TrackingMailer.welcome_email.deliver
    @bl = BillOfLading.where(status_tracking: 0)
  end

  def list_tracking
    if @current_user.nil?
      return
    end
    @bl = BillOfLading.find(params[:bid])
    if @bl.trackings.size <= 0
      @bl.shipping_instruction.vessels.each do |v|
        tracking = Tracking.new(bill_of_lading: @bl, vessel: v.vessel_name, etd_no: v.etd_no, etd_date: v.etd_date,
                                eta_no: v.eta_no, eta_date: v.eta_date, etd_actual_date: v.etd_date, eta_actual_date: v.eta_date, status: 0)
        tracking.save
      end
    end
    @trackings = Tracking.where(bill_of_lading_id: @bl.id)
    render layout: false
  end

  def update_tracking
    # unless verify_authenticity_token
    #   output = {"success" => false, "message" => "Cheating Huh?!"}
    #   render :json => output.to_json
    #   return
    # end
    tracking = Tracking.find(params[:tid])

    output = {}
    unless params[:actions] == 0
      if params[:request_type] == "etd"
        tracking.status = params[:actions]
        tracking.etd_actual_date = params[:actual_date] unless params[:actual_date].blank?
        tracking.etd_desc = params[:reason] unless params[:reason].blank?
      elsif params[:request_type] = "eta"
        tracking.status_eta = params[:actions]
        tracking.eta_actual_date = params[:actual_date] unless params[:actual_date].blank?
        tracking.eta_desc = params[:reason] unless params[:reason].blank?
      end
      tracking.vessel = params[:vessel] unless params[:vessel].blank?
      tracking.save
    end

    case params[:actions]
      when "0"
        output = {:success => false, :message => "Nothing to Update"}
      when "1"
        # TrackingMailer.tracking_confirm(params[:request_type], "melly@infopibi.com", params[:tid]).deliver
        output = {:success => true, :message => "Status Update to Confirm"}
      when "2"
        # TrackingMailer.tracking_delay(params[:request_type], "melly@infopibi.com", params[:tid]).deliver
        output = {:success => true, :message => "Status Update to Delay"}
      when "3"
        # TrackingMailer.tracking_switch(params[:request_type], "melly@infopibi.com", params[:tid]).deliver
        output = {:success => true, :message => "Status Update to Switch"}
    end
    render :json => output.to_json
  end

  def list_inv_dbn
    @invoices = InvoiceServices.find_with(params)
    @report = InvoiceReport.new
  end

  def create_new_invoice
    bill_of_lading = BillOfLading.find(params[:bid])
    shipping_instruction = bill_of_lading.shipping_instruction
    calculate_invoice = shipping_instruction.bill_of_lading_invoices.find(params[:iid]) unless params[:iid].blank?
    if shipping_instruction.is_cr_completed?
      redirect_to shipping_instruction.cost_revenue, notice: "#{shipping_instruction.ibl_ref} : CR Completed"
      return
    else
      unless calculate_invoice.blank?
        unless params[:invoice_no].blank?
          # invoice = Invoice.find_by(ibl_no: shipping_instruction.ibl_ref, no_invoice: params[:invoice_no]) if params[:invoice_no].include? "INV"
          # invoice = DebitNote.find_by(ibl_no: shipping_instruction.ibl_ref, no_dbn: params[:invoice_no]) if params[:invoice_no].include? "DBN"
          # invoice = Note.find_by(ibl_no: shipping_instruction.ibl_ref, no_note: params[:invoice_no]) if params[:invoice_no].include? "CRN"
          invoice = InvoiceServices.find_with_invoice_no(params[:invoice_no])
          
          unless invoice.blank?
            if invoice.kind_of? Invoice
              redirect_to edit_invoice_path(invoice, iid: params[:iid])
            elsif invoice.kind_of? Note
              redirect_to edit_note_path(invoice, iid: params[:iid])
            else
              redirect_to edit_debit_note_path(invoice, iid: params[:iid])
            end
          else
            redirect_to list_inv_dbn_path, notice: 'Invoice '+params[:invoice_no]+' with '+shipping_instruction.ibl_ref+' was not connected.'        
          end
        end  
      else
        redirect_to bill_of_ladings_path, notice: 'Calculate Invoice '+shipping_instruction.ibl_ref+' was not listed.'
      end
    end
    # if shipping_instruction.bill_of_lading_invoices.blank? || (!shipping_instruction.bill_of_lading_invoices.blank? && shipping_instruction.bill_of_lading_invoices.bill_of_lading_items.blank?)
    #     redirect_to bill_of_ladings_path, notice: 'Calculate Invoice '+shipping_instruction.ibl_ref+'was not created.'
    # end
  end

  def destroy
    # Agent.destroy_all
    # Attachment.destroy_all
    # BillOfLading.destroy_all
    # BillOfLadingHistory.destroy_all
    # Carrier.destroy_all
    # CarrierBank.destroy_all
    # Consignee.destroy_all
    # CostRevenue.destroy_all
    # CostRevenueItem.destroy_all
    # CustomField.destroy_all
    # DebitNote.destroy_all
    # DebitNoteDetail.destroy_all
    # Invoice.destroy_all
    # InvoiceDetail.destroy_all
    # Payment.destroy_all
    # PaymentHistory.destroy_all
    # PaymentReference.destroy_all
    # Shipper.destroy_all
    # ShippingInstruction.destroy_all
    # ShippingInstructionHistory.destroy_all
    # SiContainer.destroy_all
    # Tracking.destroy_all
    # Vessel.destroy_all

    redirect_to root_path, notice: "Database has been emptied."
  end

  def update_invoice
    # Shipping Instructions
    ShippingInstruction.find_each do |shipping_instruction|
      temp = shipping_instruction.si_no
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]
      if shipping_instruction.is_shadow?
        new_no += temp[temp.length-1]
      end
      shipping_instruction.update(si_no: new_no)
    end

    # Shipping Instruction Histories
    ShippingInstructionHistory.find_each do |si_history|
      temp = si_history.si_no
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]
      si_history.update(si_no: new_no)
    end

    # Payment References
    PaymentReference.find_each do |reference|
      temp = reference.ibl_ref
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]
      reference.update(ibl_ref: new_no)
    end

    # Bill of Ladings
    BillOfLading.find_each do |bill_of_lading|
      temp = bill_of_lading.bl_number
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]
      bill_of_lading.update(bl_number: new_no)
    end

    # Bill of Lading Histories
    BillOfLadingHistory.find_each do |bill_of_lading|
      temp = bill_of_lading.bl_number
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]
      bill_of_lading.update(bl_number: new_no)
    end

    # Debit Notes
    DebitNote.find_each do |dbn|
      temp = dbn.ibl_no
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_ibl_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]

      temp = dbn.no_dbn
      digit = temp.split("IBLDBN")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no_dbn = "IBLDBN14" + digit.to_s[1..digit.to_s.length-1]

      dbn.update(ibl_no: new_ibl_no, no_dbn: new_no_dbn)
    end

    # Invoices
    Invoice.find_each do |inv|
      temp = inv.ibl_no
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_ibl_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]

      temp = inv.no_invoice
      digit = temp.split("IBLINV")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_inv_no = "IBLINV14" + digit.to_s[1..digit.to_s.length-1]

      inv.update(ibl_no: new_ibl_no, no_invoice: new_inv_no)
    end

    #  Notes
    Note.find_each do |note|
      temp = note.ibl_no
      digit = temp.split("IBL")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_ibl_no = "IBL14" + digit.to_s[1..digit.to_s.length-1]

      temp = note.no_note
      digit = temp.split("IBLCRN")
      digit = 10000 + digit[1][digit[1].length-4..digit[1].length-1].to_i
      new_no_note = "IBLCRN14" + digit.to_s[1..digit.to_s.length-1]

      note.update(ibl_no: new_ibl_no, no_note: new_no_note)
    end

    render text: ""
  end

  def get_due_date
    begin
      bl = BillOfLading.find(params[:bl_id])
      vessel = bl.shipping_instruction.vessels.first

      if params[:type] == "Agent"
        agent = Agent.find(params[:id])
        due_date = vessel.etd_date + agent.credit_term.to_i.days
        data = {:success => true, :due => due_date.to_time.strftime('%d %B %Y')}
      elsif params[:type] == "Consignee"
        consignee = Consignee.find(params[:id])
        due_date = vessel.etd_date + consignee.credit_term.to_i.days
        data = {:success => true, :due => due_date.to_time.strftime('%d %B %Y')}
      elsif params[:type] == "Shipper"
        shipper = Shipper.find(params[:id])
        due_date = vessel.etd_date + shipper.credit_term.to_i.days
        data = {:success => true, :due => due_date.to_time.strftime('%d %B %Y')}
      else
        data = {:success => false}
      end
      render :json => data.to_json
    rescue => e
      data = {:success => false}
      render :json => data.to_json
    end
  end

  def backup

  end

  def db_backup
    require "#{Rails.root}/lib/" + "mysql.rb"
    dump = Mysql.full_backup

    if dump
      response.headers['Content-Type'] = 'text/plain'
      response.headers['Content-Disposition'] = 'attachment; filename=DATABASE_' + Date.today.to_s + '.bak'
      render :text => dump
    else
      redirect_to backup_path, notice: "Problem when trying to backup the database. Please try again."
    end
  end

  def db_restore
    begin
      require "#{Rails.root}/lib/" + "mysql.rb"
      restore = Mysql.restore(params[:name].tempfile.path)

      if restore
        redirect_to backup_path, notice: "Database has been restored"
      else
        redirect_to backup_path, notice: "Problem when trying to restore the database. Please try again."
      end
    rescue => e
      redirect_to backup_path, notice: "Please upload the backup file."
    end
  end

  def monitoring_data_refresh
    BlMonitoring.destroy_all
    BillOfLading.includes(:shipping_instruction).where(is_shadow: false, is_cancel: BillOfLading::UNCANCELED, shipping_instructions: { is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED, status: ShippingInstruction::OPENED }).find_each do |bill_of_lading|
      BlMonitoringWorker.process_bl_monitoring(bill_of_lading.id)
    end

    CrMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false).find_each do |shipping_instruction|
      CrMonitoringWorker.process_cr_monitoring(shipping_instruction.id)
    end

    PaymentMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      PaymentMonitoringWorker.process_payment_monitoring(shipping_instruction.id)
    end

    ShipmentMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false).find_each do |shipping_instruction|
      ShipmentMonitoringWorker.process_shipment_monitoring(shipping_instruction.id)
    end

    SiMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      SiMonitoringWorker.process_si_monitoring(shipping_instruction.id)
    end

    redirect_to root_path, notice: "Monitoring Data has been refreshed."
  end
end
