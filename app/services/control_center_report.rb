class ControlCenterReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns, :head_letters
  attr_accessor :format, :monthly, :from, :to, :report_type

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]
  validates_inclusion_of :report_type, in: ["customized", "breakdown", "paid"]

  # def filename(name)
  #   tmp = name
  #   tmp += " #{self.monthly}" unless self.monthly.blank?
  #   # tmp += "From: #{self.from} " unless self.from.blank?
  #   # tmp += "To: #{self.to} " unless self.from.blank?
  #   tmp.upcase
  # end

  # def title(name)
  #   tmp = name
  #   tmp += " #{self.monthly}" unless self.monthly.blank?
  #   tmp += " From: #{self.from}" unless self.from.blank?
  #   tmp += " To: #{self.to}" unless self.from.blank?
  #   tmp.upcase
  # end

  def filename
    tmp = begin
      case self.report_type
      when "breakdown"
        "Breakdown Report"
      when "paid"
        "Paid Report"
      else
        "Customized Report"
      end
    end
    tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = begin
      case self.report_type
      when "breakdown"
        "Breakdown Report"
      when "paid"
        "Paid Report"
      else
        "Customized Report"
      end
    end
    tmp += " #{self.monthly}" unless self.monthly.blank?
    tmp += " From: #{self.from}" unless self.from.blank?
    tmp += " To: #{self.to}" unless self.from.blank?
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
        data = Invoice.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
      elsif head_letter == "DEBIT NOTE" || head_letter == "REIMBURSEMENT COST"
        data = DebitNote.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
      elsif head_letter == "CREDIT NOTE"
        data = Note.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
      end
    end
    data
  end

  def orientation
    "Landscape"
  end

  def template
    case self.report_type
    when "breakdown"
      "cc_breakdown_report"
    when "paid"
      # "control_center_paid_invoice_report"
      "cc_paid_report"
    else
      # "control_center_list_invoice_report"
      "cc_report"
    end   
  end
end
