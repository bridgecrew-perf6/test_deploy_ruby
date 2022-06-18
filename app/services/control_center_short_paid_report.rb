class ControlCenterShortPaidReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns, :head_letters
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Control Center - Short Paid"
    tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Control Center - Short Paid"
    tmp += " #{self.monthly}" unless self.monthly.blank?
    tmp += " From: #{self.from}" unless self.from.blank?
    tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  def populate_data
    row_ids = self.row_ids

    data = []

    # data = InvoicePayment.includes(:invoice).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    data = InvoicePayment.includes(:close_payment).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    
    data
  end

  def template
    "cc_short_paid_report"
  end
end
