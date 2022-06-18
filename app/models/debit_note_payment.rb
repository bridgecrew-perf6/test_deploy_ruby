class DebitNotePayment < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
  	assoc.belongs_to :debit_note
  end

  delegate :currency_code, :ibl_ref, :ibl_ref_with_status, :invoice_no, to: :debit_note, allow_nil: true

  def total
  	(self.amount_paid.to_f + self.rounding.to_f + self.bank_charge.to_f + self.discount.to_f + self.short_paid.to_f + self.deposit.to_f).round(2)
  end
end
