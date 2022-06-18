class InvoiceMonitoring < ActiveRecord::Base # List Due Date Invoice
  # belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  belongs_to :shipping_instruction
  has_one :bill_of_lading, through: :shipping_instruction
  belongs_to :invoice
  belongs_to :debit_note
  belongs_to :note

  # def actual_name
  #   # "#{invoice_no} / #{shipper_company_name}"
  #   self.name
  # end

  def transit_time
    # if !self.invoice_id.blank?
    #   (Date.today - self.invoice.due_date).to_i
    # elsif !self.debit_note_id.blank?
    #   (Date.today - self.debit_note.due_date).to_i
    # elsif !self.note_id.blank?
    #   (Date.today - self.note.due_date).to_i
    # end
    inv = begin
      if !self.invoice_id.blank?
        self.invoice
      elsif !self.debit_note_id.blank?
        self.debit_note
      elsif !self.note_id.blank?
        self.note
      end
    end
    unless inv.due_date.blank?
      (DateTime.now.in_time_zone("Jakarta").to_date - inv.due_date).to_i
    end
  end
end
