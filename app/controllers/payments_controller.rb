class PaymentsController < ApplicationController
  before_filter :authorize
  before_action :set_payment, only: [:show, :edit, :update, :destroy, :email, :cancel, :uncancel]
  before_action :load_data, only: [:new, :edit, :create, :update]
  before_action :load_description, only: [:calculate_invoice]
  
  before_action :set_shipping_instruction, only: [:calculate_invoice, :update_calculate_invoice, :view_calculate_invoice]
  before_action :validate_have_cr_completed, only: [:calculate_invoice, :update_calculate_invoice]
  before_action :validate_have_reference_with_cr_completed, only: [:cancel, :uncancel]
  before_action :validate_have_deposit_detail, only: [:cancel]
  
  def index
    # @payments = Payment.with_filter(params).first(10)
    # @shipping_instructions = ShippingInstruction.get_payments_plan(params)
    # @report = PaymentPlanReport.new
    @payments = Payment.with_filter(params)
    @report = PaymentInquiryReport.new
  end

  def show
  end

  def new
    @payment = Payment.new
    # @payment.initialize_new
    @payment.initialize_new(params)

    (3 - @payment.payment_references.size).times { @payment.payment_references.build }
    # 3.times { @payment.payment_deposits.build }
  end

  def edit
  end

  def create
    @payment = Payment.new(payment_params)

    # if @payment.create!(params[:year])
    if @payment.valid?
      @payment.create!(params[:year])
      respond_to do |format|
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # if @payment.valid?
      # @payment.si_bl_no = @payment.si_bl_no.upcase
      # raise payment_params.inspect
    # valid = true
    # deposit = {}
    # payment_params[:payment_deposits_attributes].each do |key, value|
    #   if value[:_destroy].blank?
    #     if deposit[value[:ibl_ref].upcase].blank?
    #       deposit[value[:ibl_ref].upcase] = value[:amount].to_f
    #     else
    #       deposit[value[:ibl_ref].upcase] += value[:amount].to_f
    #     end
    #   end
    # end unless payment_params[:payment_deposits_attributes].blank?
    
    # payment_params[:payment_references_attributes].each do |key, value|
    #   if value[:_destroy].blank?
    #     amount_estimate = value[:amount].to_f - value[:amount_misc].to_f - value[:amount_overpaid].to_f + deposit[value[:ibl_ref].upcase].to_f
    #     deposit[value[:ibl_ref].upcase] = 0
    #     unless amount_estimate == value[:amount_invoice].to_f && (amount_estimate != 0 && value[:amount_invoice].to_f != 0)
    #       @payment.errors.add(:base, "Reference #{value[:ibl_ref].upcase} can't request")
    #       valid = false
    #     end
    #   end
    # end

    # deposit.each do |key, value|
    #   if value.to_f != 0
    #     @payment.errors.add(:base, "Use Deposit for #{key.upcase} can't request")
    #     valid = false  
    #   end
    # end 

    respond_to do |format|
      @payment.attributes = payment_params
      if @payment.valid?
        @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
    # else
    #   render "edit"
    # end
  end

  # def update_status
  #   begin
  #     payment = Payment.find(params[:id])
  #     payment_services = PaymentServices.new(payment)

  #     if payment_services.update_status!(params[:status])
  #       redirect_to payment, notice: "Status updated"
  #     end
  #   rescue
  #     redirect_to payments_path, notice: "An error occurred, please try again."
  #   end
  # end

  def cancel
    # payment = Payment.find(params[:id])
    payment_services = PaymentServices.new(@payment)

    if payment_services.cancel!
      redirect_to payment_inquiries_path, notice: "Payment Inquiry has been update to cancel" and return
    end

    redirect_to payment_inquiries_path
  end

  def uncancel
    # payment = Payment.find(params[:id])
    payment_services = PaymentServices.new(@payment)

    if payment_services.uncancel!
      redirect_to payment_inquiries_path, notice: "Payment Inquiry has been update to uncancel" and return
    end

    redirect_to payment_inquiries_path
  end

  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  def generate_number
    render text: Payment.generate_number(params[:type], params[:year])
  end

  def payments_list
    @payments = Payment.get_list(params)
    if params[:SI] && params[:query] && params[:status]
      shipping_instruction = ShippingInstruction.find_by(si_no: params[:SI])
      invoices = Invoice.includes(:bill_of_lading)
      .where("shipping_instruction_id = ? AND invoices.no_invoice LIKE ? AND status = ?", shipping_instruction.id,
             "%#{params[:query]}%", params[:status])
      .references(:bill_of_lading)
      payment_histories = PaymentHistory.where(invoice_id: invoices.map { |i| i.id }).group("payment_id")
      @payments = Payment.find(payment_histories.map { |i| i.payment_id })
    end
    respond_to do |format|
      format.json { render json: @payments, only: [:payment_no] }
    end
  end

  def plan
    @shipping_instructions = ShippingInstruction.get_payments_plan(params)
    @report = PaymentPlanReport.new
    # @payments = Payment.with_filter(params).first(10)
    render "index"
  end

  def inquiry
    @payments = Payment.with_filter(params)
    @report = PaymentInquiryReport.new
    render "index"
  end

  def tax
    # @payments = PaymentTax.with_filter(params)
    # @report = PaymentTaxReport.new
    # render "index"
    @shipping_instructions = ShippingInstruction.get_payments_tax(params)
    @report = PaymentTaxReport.new
    # @payments = Payment.with_filter(params).first(10)
    render "index"
  end
  
  def deposit
    # @payments = PaymentReference.with_filter(params)
    # @shipping_instructions = ShippingInstruction.with_filter(params)
    # ibl_ref = PaymentReference.pluck("distinct ibl_ref")
    # payments = Payment.with_filter(params)
    # @payment_references = PaymentReference.where(payment: payments).where.not(amount_invoice: nil)
    # @deposit_balance_idr = PaymentReference.joins(:payment).where("payments.payment_type = ?", "IDR")
    # @deposit_balance_usd = PaymentReference.joins(:payment).where("payments.payment_type = ?", "USD")
    # @use_deposit_idr = PaymentDeposit.joins(:payment).where("payments.payment_type = ?", "IDR")
    # @use_deposit_usd = PaymentDeposit.joins(:payment).where("payments.payment_type = ?", "USD")

    # ibl_ref = @payment_references.pluck("distinct ibl_ref")
    # # ibl_ref2 = PaymentDeposit.pluck("distinct ibl_deposit")
    # @shipping_instructions = ShippingInstruction.where(si_no: ibl_ref).first(10)



    
    # payments = Payment.with_filter(params)
    # references = PaymentReference.where(payment: payments).where.not(amount_invoice: nil)
    # ibl_ref = references.pluck("distinct ibl_ref")
    # # ibl_ref2 = PaymentDeposit.pluck("distinct ibl_deposit")
    # @shipping_instructions = ShippingInstruction.includes(:vessels, :payment_deposits, payment_references: [:payment]).where(si_no: ibl_ref)
    
    # @report = PaymentDepositReport.new
    # render "index"


    payments = Payment.with_filter(params)
    @payment_references = PaymentReference.includes(:payment, :shipping_instruction).where(payment: payments).where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > 0").references(:payment).order(ibl_ref: :desc)
    @payment_references = @payment_references.where("payments.is_cancel = ?", 0)
    # @payment_references = PaymentReference.includes(:payment, :shipping_instruction).where(payment: payments).references(:payment).order(ibl_ref: :desc).limit(10)
    # ibl_ref1 = payment_references.pluck("distinct ibl_ref")
    # ibl_ref2 = PaymentDeposit.pluck("distinct ibl_ref")
    # ibl_ref3 = PaymentDeposit.pluck("distinct ibl_deposit")
    # ibl_ref = (ibl_ref1 + ibl_ref2 + ibl_ref3).uniq

    # @shipping_instructions = ShippingInstruction.find_by(ibl_ref: ibl_ref)

    @report = PaymentDepositReport.new
    render "index"
  end

  def report
    # @shipping_instructions = ShippingInstruction.with_filter(params).first(10)
    @payment_invoices = PaymentInvoice.includes(:payment_items).with_filter(params)
    # @invoice_payment_dates = @payment_invoices.group_by { |t| t.payment_date }
    render "index"
  end

  def calculate_invoice
    # @shipping_instruction = ShippingInstruction.find(params[:sid])
    # payment_date = @shipping_instruction.first_etd_date - 3.days unless @shipping_instruction.first_etd_date.blank?
    # @shipping_instruction.payment_invoices.build([ { payment_date: payment_date, carrier: @shipping_instruction.carrier } ]) if @shipping_instruction.payment_invoices.blank?

    # @shipping_instruction.payment_invoices.each do |invoice|
    #   bl_count = invoice.payment_items.count
    #   # cr_count = @shipping_instruction.shipping_instruction.cost_revenue.blank? ? 0 : @shipping_instruction.shipping_instruction.cost_revenue.cost_revenue_items.count
    #   cr_count = 0
    #   count = 3 - ( bl_count > cr_count ? bl_count : cr_count )    
      
    #   count.times { invoice.payment_items.build }
    # end
    
    # @shipping_instruction.initialize_new_payment_invoice
    # raise @shipping_instruction.bill_of_lading_invoice.carrier_items.inspect
    @calculate_invoice = PaymentPlan.find(@shipping_instruction.id)
    @calculate_invoice.initialize_new_payment_invoice
  end

  def update_calculate_invoice
    # @shipping_instruction = ShippingInstruction.find(params[:sid])
    @calculate_invoice = PaymentPlan.find(@shipping_instruction.id)
    @calculate_invoice.attributes = invoice_payment_params
    
    if @calculate_invoice.valid?
      @calculate_invoice.save
      redirect_to view_calculate_invoice_payments_url(sid: @calculate_invoice.id), notice: 'Payment Plan was successfully updated.'
    else
      render action: 'calculate_invoice'
    end
  end

  def view_calculate_invoice
    @shipping_instruction = ShippingInstruction.find(params[:sid])
    @payment_invoices = @shipping_instruction.payment_invoices
    @cost_revenue = @shipping_instruction.cost_revenue
  end

  # def update_tax
  #   if !params[:tax_issued].blank? && !params[:tax_no].blank? && !params[:id].blank?
  #      # && (!params[:vat_10_no].blank? || !params[:vat_1_no].blank? || !params[:pph_23_no].blank?)
  #     payment_tax = PaymentTax.find(params[:id])
  #     if payment_tax
  #       payment_tax.tax_issued = Date.parse(params[:tax_issued])
  #       payment_tax.tax_no = params[:tax_no]
  #       payment_tax.is_paid = params[:paid_status] == "Yes" ? true : false
  #       payment_tax.save(validate: false)

  #       output = {'success' => true, 'message' => 'Update success', 'tax_issued' => payment_tax.tax_issued, 'tax_no' => payment_tax.tax_no, 'paid_status' => payment_tax.paid_status }
  #     else
  #       output = {'success' => false, 'message' => 'Payment Tax already closed'}
  #     end
  #   else
  #     output = {'success' => false, 'message' => 'Enter Tax Issued and Tax No'}
  #   end
  #   render :json => output.to_json
  # end

  def ibl_deposit
    begin
      # data = Payment.get_ibl_deposit(params[:carrier_bank_id], params[:cash_carrier_name], params[:payment_type])
      data = Payment.get_ibl_deposit(params)
      if data
        render json: data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def email
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def load_data
    @carriers = Carrier.search
    params2 = {}
    unless @payment.blank? 
      params2[:code] = @payment.payment_type unless @payment.payment_type.blank?
      params2[:carrier_id] = @payment.carrier_id unless @payment.carrier_id.blank?
    else
      unless params[:carrier].blank?
        carrier = Carrier.find_by(name: params[:carrier])
        params2[:carrier_id] = carrier.id unless carrier.blank?
      end
    end
    @carrier_banks = CarrierBank.search(params2)
  end

  def set_shipping_instruction
    @shipping_instruction = ShippingInstruction.find(params[:sid])
    @cost_revenue = @shipping_instruction.cost_revenue    
  end

  def load_description
    @carriers = Carrier.search
    @details = CostRevenueItem.group(:description).all
  end

  def payment_params
    params.require(:payment)
    .permit(:invoice_id, :no_invoice, :payment_type, :bl_number, :si_no, :carrier_id, :carrier_bank_id, :payment_date,
            :payment_no, :amount, :si_bl_no, :cash_carrier_name, :notes,
            # payment_references_attributes: [:id, :ibl_ref, :booking_no, :amount, :amount_invoice, :amount_payment, :_destroy],
            payment_references_attributes: [:id, :ibl_ref, :booking_no, :amount, :amount_invoice, :amount_payment, :_destroy, :master_bl_no, :amount_misc, :amount_overpaid],
            # payment_deposits_attributes: [:id, :ibl_deposit, :mbl_no, :amount, :ibl_ref, :_destroy],
            payment_deposits_attributes: [:id, :ibl_deposit, :master_bl_no, :amount, :ibl_ref, :_destroy],
            payment_taxes_attributes: [:id, :ibl_ref, :amount, :_destroy])
  end

  def invoice_payment_params
    # params.require(:shipping_instruction)
    params.require(:payment_plan)
    .permit(payment_invoices_attributes: [:id, :payment_date, :carrier, :carrier_id, :is_paid, :_destroy,
            :other, :rate, :vat_10, :vat_1, :pph_23, 
            payment_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy, :item_type],
            volume_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy, :item_type],
            shipper_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy, :item_type],
            carrier_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy, :item_type],
            active_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy, :item_type],
            fixed_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :item_type]
            ]
    )
  end

  # def compare_invoice_with_estimate
  #   valid = true
  #   deposit = {}
  #   payment_params[:payment_deposits_attributes].each do |key, value|
  #     if value[:_destroy].blank?
  #       if deposit[value[:ibl_ref].upcase].blank?
  #         deposit[value[:ibl_ref].upcase] = value[:amount].to_f
  #       else
  #         deposit[value[:ibl_ref].upcase] += value[:amount].to_f
  #       end
  #     end
  #   end unless payment_params[:payment_deposits_attributes].blank?
    
  #   payment_params[:payment_references_attributes].each do |key, value|
  #     if value[:_destroy].blank?
  #       amount_estimate = value[:amount].to_f - value[:amount_misc].to_f - value[:amount_overpaid].to_f + deposit[value[:ibl_ref].upcase].to_f
  #       deposit[value[:ibl_ref].upcase] = 0
  #       unless amount_estimate == value[:amount_invoice].to_f && (amount_estimate != 0 && value[:amount_invoice].to_f != 0)
  #         @payment.errors.add(:base, "Reference #{value[:ibl_ref].upcase} can't request")
  #         valid = false
  #       end
  #     end
  #   end

  #   deposit.each do |key, value|
  #     if value.to_f != 0
  #       @payment.errors.add(:base, "Use Deposit for #{key.upcase} can't request")
  #       valid = false  
  #     end
  #   end

  #   valid
  # end

  def validate_have_cr_completed
    redirect_to payment_plans_path, notice: "Can't edit the Payment Plan with CR status Completed" if @shipping_instruction.is_cr_completed?
  end

  def validate_have_deposit_detail
    redirect_to payment_inquiries_path, alert: "Cannot Cancel due to having Deposit Detail" if @payment.have_deposit_detail?
  end

  def validate_have_reference_with_cr_completed
    redirect_to payment_inquiries_path, alert: "Req No. #{@payment.req_no} have reference(s) with CR status Completed" if @payment.have_reference_with_cr_completed?
  end
end
