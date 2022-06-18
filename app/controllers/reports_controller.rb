# noinspection ALL
class ReportsController < ApplicationController
  before_filter :authorize
  # before_filter :is_admin, only: [:control_center, :cost_revenue_analysis]
  before_filter :is_admin, only: [:index, :cost_revenue_analysis, :balance, :detail_shipment]

  def index
    @cost_revenue_analysis_report = CostRevenueAnalysisReport.new
    @balance_report = BalanceReport.initialize_new
    @detail_shipment_report = DetailShipmentReport.new
  end

  def check_si_exists
    if ShippingInstruction.exists? si_no: params[:ibl_no]
      data = {:success => true}
    else
      data = {:success => false}
    end
    render json: data.to_json and return
  end

  def list_si
    @shipping_instructions = SIServices.get_list_si(params).first(20)

    filename = begin
      if filter = params[:filter_si_yearly].presence || params[:filter_si_monthly].presence
        "Shipping Instruction #{filter}"
      else
        "Shipping Instruction ALL"
      end
    end

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xls\""
      render format: "xls", filename: "#{filename}.xls"
    else
      html = render_to_string(layout: false, action: "list_si.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "#{filename}.pdf", type: "application/pdf", disposition: "inline")
      return
    end
  end

  def shipments_tracking
    @shipments = SIServices.get_shipments_tracking(params)

    filter_date = begin
      if filter = params[:filter_shipments_yearly].presence || params[:filter_shipments_monthly].presence
        filter
      else
        "ALL"
      end
    end

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"Shipments Tracking - #{filter_date}.xls\""
      render format: "xls", filename: "Shipments Tracking - #{filter_date}"
    else
      html = render_to_string(layout: false, action: "shipments_tracking.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "Shipments Tracking - #{filter_date}.pdf", type: "application/pdf",
                disposition: "inline")
      return
    end
  end

  def invoices
    @invoices = InvoiceServices.report_invoices(params)
    invoice_type = (params[:invoice_type].present? ? params[:invoice_type] : "Invoices")

    invoice_type = begin
      if filter = params[:filter_invoices_yearly].presence || params[:filter_invoices_monthly].presence
        "#{invoice_type} #{filter}"
      else
        "#{invoice_type} ALL"
      end
    end

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"#{invoice_type}.xls\""
      render format: "xls", filename: "#{invoice_type}"
    else
      html = render_to_string(layout: false, action: "invoices.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "#{invoice_type}.pdf", type: "application/pdf", disposition: "inline")
      return
    end
  end

  def invoices_unpaid
    @invoices = InvoiceServices.unpaid_invoices(params)

    filename = begin
      # "Invoices Unpaid" + (params[:year].to_s.empty? ? "" : " #{params[:year]}")
      if filter = params[:filter_unpaid_yearly].presence || params[:filter_unpaid_monthly].presence
        "Invoices Unpaid #{filter}"
      else
        "Invoices Unpaid ALL"
      end
    end

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xls\""
      render format: "xls", filename: "#{filename}.xls"
    else
      html = render_to_string(layout: false, action: "invoices_unpaid.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "#{filename}.pdf", type: "application/pdf", disposition: "inline")
    end
  end

  def outstanding_invoices
    @invoices = InvoiceServices.outstanding_invoices(params)

    filename = begin
      # "Invoices Unpaid" + (params[:year].to_s.empty? ? "" : " #{params[:year]}")
      if filter = params[:filter_outstanding_yearly].presence || params[:filter_outstanding_monthly].presence
        "Outstanding Invoices #{filter}"
      else
        "Outstanding Invoices ALL"
      end
    end

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"Outstanding Invoices.xls\""
      render format: "xls", filename: "#{filename}.xls"
    else
      html = render_to_string(layout: false, action: "outstanding_invoices.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "#{filename}.pdf", type: "application/pdf", disposition: "inline")
      return
    end
  end

  def payments
    # @payments = Payment.where(payment_type: params[:payment_type])
    @payments = Payment.generate_reports(params)

    payment_type = begin
      # "Invoices Unpaid" + (params[:year].to_s.empty? ? "" : " #{params[:year]}")
      if filter = params[:filter_payments_yearly].presence || params[:filter_payments_monthly].presence
        "Payments #{filter}"
      else
        "Payments ALL"
      end
    end
    # payment_type = (params[:payment_type].present? ? params[:payment_type] : "Payments")

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"#{payment_type}.xls\""
      render format: "xls", filename: "#{payment_type}.xls"
    else
      html = render_to_string(layout: false, action: "payments.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "#{payment_type}.pdf", type: "application/pdf", disposition: "inline")
      return
    end
  end

  def control_center
    params[:date_filter] = params[:filter_cc]

    @invoices = InvoiceServices.find_with_vessels(params)
    @shipping_instructions = InvoiceServices.get_shipping_instructions(@invoices, params)

    # invoices_sql = "SELECT I.no_invoice as no_invoice, I.id as invoice_id, I.is_cancel as cancel_inv, I.status_payment as status_payment, I.currency_code, I.to_shipper, I.destination, " +
    #   "I.bill_of_lading_id, ISI.si_no, I.is_cancel as is_cancel, I.customer as customer, I.customer_ori as customer_ori, I.invoice_date as invoice_date, I.due_date as due_date, " +
    #   "I.date_of_payment as date_of_payment, I.notes_payment as notes_payment FROM invoices I " +
    #   "LEFT OUTER JOIN bill_of_ladings IBL ON (IBL.id = I.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions ISI ON (ISI.id = IBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels IVS ON (IVS.id = (SELECT IV.id FROM vessels IV WHERE IV.shipping_instruction_id = ISI.id LIMIT 1)) "
    # debit_notes_sql = "SELECT D.no_dbn as no_invoice, D.id as invoice_id, D.is_cancel as cancel_inv, D.status_payment as status_payment, D.currency_code, D.to_shipper, D.destination, " +
    #   "D.bill_of_lading_id, DSI.si_no, D.is_cancel as is_cancel, D.customer as customer, D.customer_ori as customer_ori, D.dbn_date as invoice_date, D.due_date as due_date, " +
    #   "D.date_of_payment as date_of_payment, D.notes_payment as notes_payment FROM debit_notes D " +
    #   "LEFT OUTER JOIN bill_of_ladings DBL ON (DBL.id = D.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions DSI ON (DSI.id = DBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels DVS ON (DVS.id = (SELECT DV.id FROM vessels DV WHERE DV.shipping_instruction_id = DSI.id LIMIT 1)) "
    # notes_sql = "SELECT N.no_note as no_invoice, N.id as invoice_id, N.is_cancel as cancel_inv, N.status_payment as status_payment, N.currency_code, N.to_shipper, N.destination, " +
    #   "N.bill_of_lading_id, NSI.si_no, N.is_cancel as is_cancel, N.customer as customer, N.customer_ori as customer_ori, N.note_date as invoice_date, N.due_date as due_date, " +
    #   "N.date_of_payment as date_of_payment, N.notes_payment as notes_payment FROM notes N " +
    #   "LEFT OUTER JOIN bill_of_ladings NBL ON (NBL.id = N.bill_of_lading_id) " +
    #   "LEFT OUTER JOIN shipping_instructions NSI ON (NSI.id = NBL.shipping_instruction_id) " +
    #   "LEFT OUTER JOIN vessels NVS ON (NVS.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = NSI.id LIMIT 1)) "
    #
    # begin
    #   date = Date.parse(params[:filter_cc])
    #   invoices_sql += "WHERE (IVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND I.is_cancel = 0 "
    #   debit_notes_sql += "WHERE (DVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND D.is_cancel = 0 "
    #   notes_sql += "WHERE (NVS.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND N.is_cancel = 0 "
    #   # invoices_sql += "WHERE (I.invoice_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #   # debit_notes_sql += "WHERE (D.dbn_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #   # notes_sql += "WHERE (N.note_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') "
    #   if params[:status].to_i != -1
    #     invoices_sql += "AND status_payment = #{params[:status]} "
    #     debit_notes_sql += "AND status_payment = #{params[:status]} "
    #     notes_sql += "AND status_payment = #{params[:status]} "
    #   end
    # rescue
    #   if params[:status].to_i != -1
    #     invoices_sql += "WHERE status_payment = #{params[:status]} "
    #     debit_notes_sql += "WHERE status_payment = #{params[:status]} "
    #     notes_sql += "WHERE status_payment = #{params[:status]} "
    #   end
    # end
    #
    # invoices_sql += "GROUP BY I.no_invoice "
    # debit_notes_sql += "GROUP BY D.no_dbn "
    # notes_sql += "GROUP BY N.no_note "
    #
    # sql = "#{invoices_sql} UNION ALL #{debit_notes_sql} UNION ALL #{notes_sql} ORDER BY si_no ASC"
    # @invoices = Invoice.find_by_sql(sql)
    #
    # begin
    #   if @invoices.any?
    #     available_si = @invoices.map { |e| e.bill_of_lading.shipping_instruction.id }.join(", ")
    #     si_query = "SELECT SI.* FROM shipping_instructions SI " +
    #       "LEFT OUTER JOIN vessels ON (vessels.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = SI.id LIMIT 1)) " +
    #       "WHERE SI.id NOT IN (#{available_si}) AND (vessels.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND is_shadow = 0 AND is_cancel = 0"
    #   else
    #     si_query = "SELECT SI.* FROM shipping_instructions SI " +
    #       "LEFT OUTER JOIN vessels ON (vessels.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = SI.id LIMIT 1)) " +
    #       "WHERE (vessels.etd_date BETWEEN '#{date.at_beginning_of_month}' AND '#{date.end_of_month}') AND is_shadow = 0 AND is_cancel = 0"
    #   end
    #   @shipping_instructions = ShippingInstruction.find_by_sql(si_query)
    # rescue => e
    #   @shipping_instructions = ShippingInstruction.none
    # end

    if params[:format] == "xls"
      headers["Content-Disposition"] = "attachment; filename=\"Control Center.xls\""
      render format: "xls", filename: "Control Center"
    else
      html = render_to_string(layout: false, action: "control_center.pdf.html.erb", formats: [:html], handler: [:erb])
      kit = PDFKit.new(html, orientation: "Landscape")
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
      send_data(kit.to_pdf, filename: "Control Center.pdf", type: "application/pdf", disposition: "inline")
      return
    end
  end

  # def cost_revenue_analysis
  #   @cost_revenues = SIServices.get_cost_revenues(params)

  #   filter_date = begin
  #     # "Invoices Unpaid" + (params[:year].to_s.empty? ? "" : " #{params[:year]}")
  #     if filter = params[:filter_cra_yearly].presence || params[:filter_cra_monthly].presence
  #       filter
  #     else
  #       "ALL"
  #     end
  #   end
  #   # filter_date = (params[:filter_cra].present? ? params[:filter_cra] : "ALL")

  #   if params[:format] == "xls"
  #     headers["Content-Disposition"] = "attachment; filename=\"CRA #{filter_date}.xls\""
  #     render format: "xls", filename: "CRA #{filter_date}"
  #   else
  #     # html = render_to_string(layout: false, action: "cost_revenue_analysis.pdf.html.erb", formats: [:html], handler: [:erb])
  #     # kit = PDFKit.new(html)
  #     # kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
  #     # send_data(kit.to_pdf, filename: "CRA #{filter_date}.pdf", type: "application/pdf", disposition: "inline")
  #     render "reports/html/_cost_revenue_analysis_report"
  #     return
  #   end
  # end

  def cost_revenue_analysis
    @report = CostRevenueAnalysisReport.new(cost_revenue_analysis_report_params)
    generate_report(@report)
  end

  def balance
    @report = BalanceReport.new(balance_report_params)
    @params = balance_report_params[:rows]
    if @report.valid?
      @balance = @report
      generate_report(@report)
    end
    return
  end

  def detail_shipment
    @report = DetailShipmentReport.new(detail_shipment_report_params)
    generate_report(@report)
  end

  def cost_revenue_analysis_index
    @cost_revenue_analysis_report = CostRevenueAnalysisReport.new
    render :template => "reports/form/_cost_revenue_analysis"
  end

  def balance_index
    @balance_report = BalanceReport.initialize_new
    render :template => "reports/form/_balance"
  end

  def detail_shipment_index
    @detail_shipment_report = DetailShipmentReport.new
    render :template => "reports/form/_detail_shipment"
  end

  private
  def cost_revenue_analysis_report_params
    params.require(:cost_revenue_analysis_report).permit(:format, :filter_by, :yearly, :monthly, :from, :to)
  end

  def balance_report_params
    params.require(:balance_report).permit(:format, 
      rows: [:description, :amount_usd, :amount_idr, :rate])
  end

  def detail_shipment_report_params
    params.require(:detail_shipment_report).permit(:format, :ibl_ref)
  end
end
