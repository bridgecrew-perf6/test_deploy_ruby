class InvoiceCloseDeposit < ActiveRecord::Base
  include UpcaseAttributes

  validates_presence_of :invoice_no, :payment_date, :amount
end
