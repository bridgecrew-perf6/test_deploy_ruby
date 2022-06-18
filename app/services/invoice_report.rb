class InvoiceReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns, :head_letters
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Invoices & Taxes"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Invoices & Taxes"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  def populate_data
    # invoices = Invoice.includes(bill_of_lading: [ :shipping_instruction ]).recent
    # debit_notes = DebitNote.includes(bill_of_lading: [ :shipping_instruction ]).recent
    # notes = Note.includes(bill_of_lading: [ :shipping_instruction ]).recent

    row_ids = self.row_ids
    head_letters = self.head_letters
    
    data = []

    if head_letters.uniq.length > 1
      row_ids.each_with_index do |row, index|
        if head_letters[index] == "INVOICE"
          data.push Invoice.find(row)
        elsif head_letters[index] == "DEBIT NOTE" || head_letters[index] == "REIMBURSEMENT COST"
          data.push DebitNote.find(row)
        elsif head_letters[index] == "CREDIT NOTE"
          data.push Note.find(row)
        end
      end
    else
      head_letter = head_letters.uniq.first
      if head_letter == "INVOICE"
        data = Invoice.includes(:shipping_instruction, invoice_details: [ :invoice ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
      elsif head_letter == "DEBIT NOTE" || head_letter == "REIMBURSEMENT COST"
        data = DebitNote.includes(:shipping_instruction, invoice_details: [ :debit_note ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
      elsif head_letter == "CREDIT NOTE"
        data = Note.includes(:shipping_instruction, invoice_details: [ :note ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
      end
    end
    data
  end

  def template
    "invoice_report"
  end
end
