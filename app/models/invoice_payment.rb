class InvoicePayment < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :_destroy

  with_options touch: true do |assoc|
  #   assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  #   assoc.belongs_to :invoice, foreign_key: 'invoice_no', primary_key: 'no_invoice'
  #   assoc.belongs_to :debit_note, foreign_key: 'invoice_no', primary_key: 'no_dbn'
  #   assoc.belongs_to :note, foreign_key: 'invoice_no', primary_key: 'no_note'

    assoc.belongs_to :close_payment
  end

  delegate :currency_2, :payment_date, :customer, :close_ref, :ibl_ref, :ibl_deposit_invoice_no, to: :close_payment, allow_nil: true

  def short_paid_status_text
  	self.short_paid_status == 1 ? 'Close' : 'Open'
  end

  def deposit_status_text
  	self.deposit_status == 1 ? 'Close' : 'Open'
  end

  def is_short_paid_open?
    self.short_paid_status == 0
  end

  def is_short_paid_close?
    self.short_paid_status == 1
  end
end
