class PaymentTaxesController < ApplicationController
  before_filter :authorize

  def index
    @shipping_instructions = ShippingInstruction.get_payments_tax(params)
    @report = PaymentTaxReport.new
    render "payments/index"
  end

  def update_tax
    # if !params[:tax_issued].blank? && !params[:tax_no].blank? && !params[:id].blank? && !params[:vat_type].blank? && !params[:invoice_no].blank? && !params[:status].blank?
    # if !params[:tax_issued].blank? && !params[:tax_no].blank? && !params[:id].blank? && !params[:vat_type].blank? && !params[:invoice_no].blank?
      invoice = PaymentInvoice.find(params[:id])
      if invoice
        if params[:vat_type] == "VAT 10%"
          invoice.vat_10_tax_no = params[:tax_no]
          invoice.vat_10_tax_issued = Date.parse(params[:tax_issued])
          invoice.vat_10_invoice_no = params[:invoice_no]
          # invoice.vat_10_status = params[:status] == 'Close' ? true : false
          invoice.save(validate: false)

          # output = {'success' => true, 'message' => 'Update success', 'tax_no' => invoice.vat_10_tax_no, 'tax_issued' => invoice.vat_10_tax_issued, 'invoice_no' => invoice.vat_10_invoice_no, 'status' => invoice.vat_10_status_text }
          output = {'success' => true, 'message' => 'Update success', 'tax_no' => invoice.vat_10_tax_no, 'tax_issued' => invoice.vat_10_tax_issued, 'invoice_no' => invoice.vat_10_invoice_no }
        
        elsif params[:vat_type] == "VAT 1%"
          invoice.vat_1_tax_no = params[:tax_no]
          invoice.vat_1_tax_issued = Date.parse(params[:tax_issued])
          invoice.vat_1_invoice_no = params[:invoice_no]
          # invoice.vat_1_status = params[:status] == 'Close' ? true : false
          invoice.save(validate: false)

          # output = {'success' => true, 'message' => 'Update success', 'tax_no' => invoice.vat_1_tax_no, 'tax_issued' => invoice.vat_1_tax_issued, 'invoice_no' => invoice.vat_1_invoice_no, 'status' => invoice.vat_1_status_text }
          output = {'success' => true, 'message' => 'Update success', 'tax_no' => invoice.vat_1_tax_no, 'tax_issued' => invoice.vat_1_tax_issued, 'invoice_no' => invoice.vat_1_invoice_no }
        
        elsif params[:vat_type] == "PPH 23"
          invoice.pph_23_tax_no = params[:tax_no]
          invoice.pph_23_tax_issued = Date.parse(params[:tax_issued])
          invoice.pph_23_invoice_no = params[:invoice_no]
          # invoice.pph_23_status = params[:status] == 'Close' ? true : false
          invoice.save(validate: false)

          # output = {'success' => true, 'message' => 'Update success', 'tax_no' => invoice.pph_23_tax_no, 'tax_issued' => invoice.pph_23_tax_issued, 'invoice_no' => invoice.pph_23_invoice_no, 'status' => invoice.pph_23_status_text }
          output = {'success' => true, 'message' => 'Update success', 'tax_no' => invoice.pph_23_tax_no, 'tax_issued' => invoice.pph_23_tax_issued, 'invoice_no' => invoice.pph_23_invoice_no }

        end
      else
        output = {'success' => false, 'message' => 'Payment Tax not existed'}
      end
    # else
    #   output = {'success' => false, 'message' => 'Enter Tax No, Tax Issued, and Invoice No'}
    # end
    render :json => output.to_json
  end

  def update_status
    begin
      payment_plan = PaymentInvoice.find(params[:invoice_id])
      unless payment_plan.blank?
        status_valid = ['Open', 'Close'].include?(params[:status])
        status = (params[:status] == 'Close') ? true : false
        if params[:vat_type] == "VAT 10%"
          payment_plan.update(vat_10_status: status) if status_valid
          status = payment_plan.vat_10_status_text
        elsif params[:vat_type] == "VAT 1%"
          payment_plan.update(vat_1_status: status) if status_valid
          status = payment_plan.vat_1_status_text
        elsif params[:vat_type] == "PPH 23"
          payment_plan.update(pph_23_status: status) if status_valid
          status = payment_plan.pph_23_status_text
        end
        data = {success: true, status: status}
        render json: data.to_json and return
      else
        raises
      end
    rescue => ex
      head 200
    end
    return
  end

  def report
    @report = PaymentTaxReport.new(report_params)
    generate_report(@report)
  end

  private
  def report_params
    # params.require(:payment_tax_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
    params.require(:payment_tax_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], vat_types: [])
  end
end
