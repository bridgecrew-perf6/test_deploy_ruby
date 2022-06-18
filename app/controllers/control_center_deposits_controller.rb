class ControlCenterDepositsController < ApplicationController
  before_filter :authorize
  # before_action :set_invoice, only: [:view, :payment, :update_payment]
  before_action :set_invoice, only: [:view, :close]
  before_action :is_admin, only: [:close]
  
  def index
    @invoices = InvoiceServices.find_with_deposit(params)
    @report = ControlCenterDepositReport.new
    render "control_centers/index"
  end

  def view
    @additionals = InvoicePayment.includes(:close_payment).where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL").references(:close_payment)
    @deposits = InvoiceDeposit.includes(:close_payment).where.not("invoice_deposits.amount IN ('0','') OR invoice_deposits.amount IS NULL").references(:close_payment)
    
    # @additionals = @additionals.where("close_payments.invoice_no = ? AND close_payments.is_shadow = ?", @invoice.invoice_no, false)
    @additionals = @additionals.where("invoice_payments.invoice_no = ? AND close_payments.is_shadow = ?", @invoice.invoice_no, false)
    @deposits = @deposits.where("invoice_deposits.invoice_deposit = ? AND close_payments.is_shadow = ?", @invoice.invoice_no, false)
    # @additionals - @additionals.where("close_payments.is_shadow = ?", false)

    @close_deposit = InvoiceCloseDeposit.where(invoice_no: @invoice.invoice_no)
    @close_deposit = @close_deposit.blank? ? InvoiceCloseDeposit.new(invoice_no: @invoice.invoice_no) : @close_deposit.first
    @currency = (@additionals.map(&:currency_2) + @deposits.map(&:currency_2)).uniq.first
  end

  def report
    @report = ControlCenterDepositReport.new(report_params)
    generate_report(@report)
  end

  def update_deposit
    if !params[:deposit_closing_date].blank? && !params[:deposit_status].blank? && !params[:id].blank?
      payment = InvoicePayment.find(params[:id])
      if payment
        payment.deposit_closing_date = Date.parse(params[:deposit_closing_date])
        payment.deposit_status = params[:deposit_status] == "Close" ? 1 : 0
        payment.deposit_note = params[:deposit_note]

        payment.save(validate: false)

        output = {'success' => true, 'message' => 'Update success', 'closing_date' => payment.deposit_closing_date, 'note' => payment.deposit_note, 'status' => payment.deposit_status_text }
      else
        output = {'success' => false, 'message' => 'Additional not existed'}
      end
    else
      output = {'success' => false, 'message' => 'Please Enter Closing Date & Status'}
    end
    render :json => output.to_json
  end

  def close
    # @close_deposit = InvoiceCloseDeposit.where(invoice_no: close_deposit_params[:invoice_no])
    @close_deposit = InvoiceCloseDeposit.where(invoice_no: @invoice.invoice_no)
    @close_deposit = @close_deposit.blank? ? InvoiceCloseDeposit.new(invoice_no: @invoice.invoice_no) : @close_deposit.first
    @close_deposit.attributes = close_deposit_params
    if @close_deposit.valid?
      @close_deposit.save
      redirect_to view_control_center_deposits_path(invoice_no: @close_deposit.invoice_no), notice: 'Close Deposit was successfully updated.'
    else
      redirect_to view_control_center_deposits_path(invoice_no: @close_deposit.invoice_no), notice: 'Close Deposit is not valid.'
    end
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

  # def report_params
  #   params.require(:control_center_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], head_letters: [])
  # end

  def report_params
    # params.require(:control_center_deposit_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
    params.require(:control_center_deposit_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], ibl_refs: [], carrier_ids: [], payment_types: [])
  end

  def close_deposit_params
    params.require(:invoice_close_deposit).permit(:invoice_no, :payment_date, :amount, :note)
  end
end
