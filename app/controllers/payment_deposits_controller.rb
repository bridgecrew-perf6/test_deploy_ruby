class PaymentDepositsController < ApplicationController
  before_filter :authorize
  before_action :set_shipping_instruction, only: [:view]
  before_action :is_admin, only: [:close]

  def index
    payments = Payment.with_filter(params)
    @payment_references = PaymentReference.includes(:payment, :shipping_instruction).where(payment: payments).where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > 0").references(:payment).order(ibl_ref: :desc)
    @payment_references = @payment_references.where("payments.is_cancel = ?", 0)
    @report = PaymentDepositReport.new
    render "payments/index"
  end
  
  def view
    # @payment_references = PaymentReference.where.not(amount_invoice: nil).where("amount_invoice < amount").where(ibl_ref: @shipping_instruction.ibl_ref)
    # @payment_deposits = PaymentDeposit.where(ibl_deposit: @shipping_instruction.ibl_ref)
    @payment_references = PaymentReference.includes(:payment, :shipping_instruction).where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > ?", 0).where(ibl_ref: @shipping_instruction.ibl_ref).references(:payment, :shipping_instruction)
    @payment_deposits = PaymentDeposit.includes(:payment, :shipping_instruction).where(ibl_deposit: @shipping_instruction.ibl_ref).references(:payment, :shipping_instruction)

    @payment_references = @payment_references.where("payments.carrier_id = ?", params[:carrier_id])
    @payment_deposits = @payment_deposits.where("payments.carrier_id = ?", params[:carrier_id])

    @payment_references = @payment_references.where("payments.is_cancel = ?", 0)
    @payment_deposits = @payment_deposits.where("payments.is_cancel = ?", 0)

    @close_deposit = PaymentCloseDeposit.where(ibl_ref: @shipping_instruction.ibl_ref, carrier: @carrier, payment_type: @payment_type)
    # @close_deposit = PaymentCloseDeposit.new if @close_deposit.blank?

    @payment_references = @payment_references.where("payments.payment_type = ?", @payment_type)
    @payment_deposits = @payment_deposits.where("payments.payment_type = ?", @payment_type)

    @payments = @payment_references + @payment_deposits + @close_deposit
    # @payments.sort_by{|a| a.payment_date}

    @close_deposit = @close_deposit.blank? ? PaymentCloseDeposit.new(ibl_ref: @shipping_instruction.ibl_ref, carrier: @carrier, payment_type: @payment_type) : @close_deposit.first

    # @payments.sort_by{|a| a.payment_no.split('/')[0].to_i}
  end

  def close
    @close_deposit = PaymentCloseDeposit.where(carrier_id: close_deposit_params[:carrier_id], ibl_ref: close_deposit_params[:ibl_ref], payment_type: close_deposit_params[:payment_type])
    if @close_deposit.blank?
      @close_deposit = PaymentCloseDeposit.new(close_deposit_params)
      @close_deposit.save
    else
      @close_deposit = @close_deposit.first
      @close_deposit.update(close_deposit_params)
    end
    # raise @close_deposit.inspect
    redirect_to view_payment_deposits_path(carrier_id: @close_deposit.carrier_id, ibl_ref: @close_deposit.ibl_ref, payment_type: @close_deposit.payment_type), notice: 'Close Deposit was successfully updated.'
  end

  def report
    @report = PaymentDepositReport.new(report_params)
    generate_report(@report)
  end

  private
  def set_shipping_instruction
    # @payment_deposit = PaymentReference.find(params[:id])
    unless params[:carrier_id].blank? || params[:ibl_ref].blank? || params[:payment_type].blank?
      @shipping_instruction = ShippingInstruction.where(si_no: params[:ibl_ref]).first
      @carrier = Carrier.find(params[:carrier_id])
      @payment_type = params[:payment_type]
    else
      redirect_to payment_deposits_path, notice: 'Invalid URI.'
    end
  end

  def report_params
    params.require(:payment_deposit_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], ibl_refs: [], carrier_ids: [], payment_types: [])
  end

  def close_deposit_params
    params.require(:payment_close_deposit).permit(:carrier_id, :ibl_ref, :payment_type, :payment_date, :amount, :note)
  end
end
