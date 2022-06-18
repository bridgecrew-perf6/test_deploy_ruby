class ControlCenterShortPaidsController < ApplicationController
  before_filter :authorize
  # before_action :set_invoice, only: [:view, :payment, :update_payment]
  before_action :is_admin, only: [:update_short_paid]
  
  def index
    @invoices = InvoiceServices.find_with_short_paid(params)
    @report = ControlCenterShortPaidReport.new
    render "control_centers/index"
  end

  def view

  end

  def report
    @report = ControlCenterShortPaidReport.new(report_params)
    generate_report(@report)
  end

  def update_short_paid
    if !params[:short_paid_closing_date].blank? && !params[:short_paid_status].blank? && !params[:id].blank?
      payment = InvoicePayment.find(params[:id])
      if payment
        payment.short_paid_closing_date = Date.parse(params[:short_paid_closing_date])
        payment.short_paid_status = params[:short_paid_status] == "Close" ? 1 : 0
        payment.short_paid_note = params[:short_paid_note]

        payment.save(validate: false)

        output = {'success' => true, 'message' => 'Update success', 'closing_date' => payment.short_paid_closing_date, 'note' => payment.short_paid_note, 'status' => payment.short_paid_status_text }
      else
        output = {'success' => false, 'message' => 'Additional not existed'}
      end
    else
      output = {'success' => false, 'message' => 'Please Enter Closing Date & Status'}
    end
    render :json => output.to_json
  end

  private
  def set_invoice
    # @invoice = Invoice.find_by(no_invoice: params[:invoice_no]) if params[:invoice_no].include? "INV"
    # @invoice = DebitNote.find_by(no_dbn: params[:invoice_no]) if params[:invoice_no].include? "DBN"
    # @invoice = Note.find_by(no_note: params[:invoice_no]) if params[:invoice_no].include? "CRN"
    @invoice = InvoiceServices.find_with_invoice_no(params[:invoice_no])
  end

  def invoice_params
    params.require(:invoice).permit(:status_payment,
      invoice_payments_attributes: [:id, :payment_date, :amount_paid, :rounding, :bank_charge, :discount, :short_paid, :deposit, :note, :_destroy],
      )
  end

  def debit_note_params
    params.require(:debit_note).permit(:status_payment,
      invoice_payments_attributes: [:id, :payment_date, :amount_paid, :rounding, :bank_charge, :discount, :short_paid, :deposit, :note, :_destroy],
      )
  end

  def note_params
    params.require(:note).permit(:status_payment,
      invoice_payments_attributes: [:id, :payment_date, :amount_paid, :rounding, :bank_charge, :discount, :short_paid, :deposit, :note, :_destroy],
      )
  end

  def report_params
    params.require(:control_center_short_paid_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
  end
end
