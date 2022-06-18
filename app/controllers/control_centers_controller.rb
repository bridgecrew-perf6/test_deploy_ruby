class ControlCentersController < ApplicationController
  before_filter :authorize
  before_action :set_invoice, only: [:view, :payment, :update_payment]
  before_action :is_admin, only: [:payment, :update_payment, :close_payment, :edit_close_payment, :update_close_payment]
  # before_action :set_invoice2, only: [:close_payment]
  
  def index
    # @invoices = InvoiceServices.find_with_vessels(params).first(10)
    @invoices = InvoiceServices.find_with_payments(params)
    # @shipping_instructions = InvoiceServices.get_shipping_instructions(@invoices, params)

    @report = ControlCenterReport.new
  end

  def view
    # @additional = @invoice.invoice_payments.where.not(close_payment_id: nil)

    @additionals = InvoicePayment.includes(:close_payment).where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL").references(:close_payment)
    @deposits = InvoiceDeposit.includes(:close_payment).where.not("invoice_deposits.amount IN ('0','') OR invoice_deposits.amount IS NULL").references(:close_payment)
    
    @additionals = @additionals.where("invoice_payments.invoice_no = ? AND close_payments.is_shadow = ?", @invoice.invoice_no, false)
    @deposits = @deposits.where("invoice_deposits.invoice_deposit = ? AND close_payments.is_shadow = ?", @invoice.invoice_no, false)
    
    @close_deposit = InvoiceCloseDeposit.where(invoice_no: @invoice.invoice_no)
    @close_deposit = @close_deposit.blank? ? InvoiceCloseDeposit.new(invoice_no: @invoice.invoice_no) : @close_deposit.first
    @currency = (@additionals.map(&:currency_2) + @deposits.map(&:currency_2)).uniq.first


    @additionals_2 = InvoicePayment.includes(:close_payment).where.not("invoice_payments.short_paid IN ('0','') OR invoice_payments.short_paid IS NULL").references(:close_payment)
    @additionals_2 = @additionals_2.where("invoice_payments.invoice_no = ? AND close_payments.is_shadow = ?", @invoice.invoice_no, false)
  end

  def payment
    @invoice.invoice_payments.build(payment_date: @invoice.date_of_payment, note: @invoice.notes_payment) if @invoice.invoice_payments.blank?
  end

  def update_payment
    # params = invoice_params if @invoice.invoice_no.include? "INV"
    # params = debit_note_params if @invoice.invoice_no.include? "DBN"
    # params = note_params if @invoice.invoice_no.include? "CRN"
    # if @invoice.update(params)
    #   redirect_to view_control_centers_url(invoice_no: @invoice.invoice_no), notice: 'Invoice Payments was successfully updated.'
    # else
    #   render action: 'calculate_invoice'
    # end
    params = invoice_params if @invoice.invoice_no.include? "INV"
    params = debit_note_params if @invoice.invoice_no.include? "DBN"
    params = note_params if @invoice.invoice_no.include? "CRN"
    if @invoice.update(params)
      redirect_to view_control_centers_url(invoice_no: @invoice.invoice_no), notice: 'Invoice Payments was successfully updated.'
    else
      redirect_to view_control_centers_url(invoice_no: @invoice.invoice_no), notice: 'Invoice Payments was failed updated.'
    end
  end

  def close_payment
    # @invoices = Invoice.where(no_invoice: close_payment_params[:invoice_no])
    # @invoices = ClosePayment.initialize_new(close_payment_params)
    # @invoice = InvoiceServices.initialize_new_close_payments(close_payment_params)
    @invoice = InvoiceServices.initialize_new_close_payments(close_payment_params)
  end

  def edit_close_payment
    # @invoices = Invoice.where(no_invoice: close_payment_params[:invoice_no])
    # @invoices = ClosePayment.initialize_new(close_payment_params)
    # @invoice = InvoiceServices.initialize_new_close_payments(close_payment_params)
    @invoice = InvoiceServices.initialize_edit_close_payments(params)
    render "close_payment"
  end

  def update_close_payment
    # @invoice = Invoice.first
    @invoice = BulkClosePayment.first
    # if @invoice.update(close_payment_with_additional_params)
    #   @invoice.close_payments.each do |payment|
    #     @invoice.invoice_payments.where(invoice_no: payment.invoice_no).update_all(close_payment: payment)
    #   end
    #   @invoice.close_payments.update_all(invoice_id: nil, batch_id: ClosePayment.pluck("distinct batch_id").count+1)
    #   raise
    #   # redirect_to view_control_centers_url(invoice_no: @invoice.invoice_no), notice: 'Invoice Payments was successfully updated.'
    # else
    #   render action: 'index'
    # end
    @invoice.attributes = close_payment_with_additional_params
    # @invoice.errors.add(:base, "Payment Date and Status can't be blank") if @invoice.close_payment_date.blank? || @invoice.close_payment_status.blank?
    
    if @invoice.valid?
      if @invoice.close_payment_close_ref.blank?
        @invoice.save
        notice = "Close Payment was successfully created."
      elsif @invoice.close_payment_close_ref == params[:close_ref]
        @invoice.save if @invoice.close_payment_is_changed?
        notice = "Close Payment was successfully updated."
      end
      # @invoice.close_payments.each do |payment|
      #   @invoice.additional_payments.where(invoice_no: payment.invoice_no).update_all(invoice_id: nil, ibl_ref: payment.ibl_ref, close_payment_id: payment.id)
      # end
      # @invoice.close_payments.update_all(invoice_id: nil, batch_id: ClosePayment.pluck("distinct batch_id").count+1)

      # render action: 'close_payment'
      # redirect_to view_control_centers_url(invoice_no: @invoice.invoice_no), notice: 'Invoice Payments was successfully updated.'
      # redirect_to control_centers_url, notice: "Close Payment was successfully created."
      redirect_to edit_close_payment_control_centers_path(:close_ref => @invoice.close_payments.first.close_ref), notice: notice
    else
      render action: 'close_payment'
    end
  end

  def ibl_ref_with_invoice_no
    begin
      data = InvoiceServices.get_ibl_ref_with_invoice_no(params)
      if data
        render json: data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def invoice_deposit
    begin
      # data = Invoice.get_invoice_deposit(params)
      data = BulkClosePayment.get_invoice_deposit(params)
      if data
        render json: data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def report
    @report = ControlCenterReport.new(report_params)
    generate_report(@report)
  end

  private
  def set_invoice
    # @invoice = Invoice.find_by(no_invoice: params[:invoice_no]) if params[:invoice_no].include? "INV"
    # @invoice = DebitNote.find_by(no_dbn: params[:invoice_no]) if params[:invoice_no].include? "DBN"
    # @invoice = Note.find_by(no_note: params[:invoice_no]) if params[:invoice_no].include? "CRN"
    @invoice = InvoiceServices.find_with_invoice_no(params[:invoice_no])
  end

  # def set_invoice2
  #   invoice_no = close_payment_params[:invoice_no][0]
  #   @invoice = Invoice.find_by(no_invoice: invoice_no) if invoice_no.include? "INV"
  #   @invoice = DebitNote.find_by(no_dbn: invoice_no) if invoice_no.include? "DBN"
  #   @invoice = Note.find_by(no_note: invoice_no) if invoice_no.include? "CRN"
  # end

  def invoice_params
    # params.require(:invoice).permit(:status_payment,
    #   invoice_payments_attributes: [:id, :payment_date, :amount_paid, :rounding, :bank_charge, :discount, :short_paid, :deposit, :note, :_destroy],
    #   )
    params.require(:invoice).permit(:status_payment, :date_of_payment, :notes_payment)
  end

  def debit_note_params
    params.require(:debit_note).permit(:status_payment, :date_of_payment, :notes_payment)
  end

  def note_params
    params.require(:note).permit(:status_payment, :date_of_payment, :notes_payment)
  end

  def report_params
    params.require(:control_center_report).permit(:format, :monthly, :from, :to, :report_type, row_ids: [], columns: [], head_letters: [])
  end

  def close_payment_params
    params.require(:control_center_close_payment).permit(invoice_no: [])
  end

  def close_payment_with_additional_params
    # params.require(:invoice).permit(:date_of_payment, :status_payment, 
    params.require(:bulk_close_payment).permit(:date_of_payment, :status_payment, 
      :close_payment_rate, :close_payment_date, :close_payment_status, :close_payment_close_ref,
      close_payments_attributes: [:id, :ibl_ref, :customer, :shipper, :invoice_no, :amount, :amount_paid, :currency, :rate, :payment_date, :status, :_destroy, :close_ref], 
      additional_payments_attributes: [:id, :payment_date, :amount_paid, :rounding, :bank_charge, :discount, :short_paid, :deposit, :note, :_destroy, :ibl_ref, :invoice_no, :pph_23, :other],
      deposit_payments_attributes: [:id, :invoice_deposit, :ibl_deposit, :amount, :invoice_no, :_destroy]
      )
  end
end
