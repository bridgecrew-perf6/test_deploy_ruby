class PaymentReportsController < ApplicationController
  before_filter :authorize
  
  def index
    @payment_invoices = PaymentInvoice.includes(:payment_items).with_filter(params)
    render "payments/index"
  end
end
