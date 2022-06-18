class InvoiceDeposit < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :_destroy

  with_options touch: true do |assoc|
    assoc.belongs_to :close_payment
  end

  validates_presence_of :invoice_deposit, :invoice_no, :amount

  delegate :currency_2, :payment_date, :customer, :close_ref, :ibl_ref, :ibl_deposit_invoice_no, to: :close_payment, allow_nil: true
end
