class PaymentTaxReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns, :vat_types
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
  	tmp = "Tax"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Tax"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  def populate_data
    row_ids = self.row_ids

    data = []
    # data = PaymentTax.includes(:shipping_instruction, payment: [ carrier_bank: [:carrier] ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    data = PaymentInvoice.includes(:shipping_instruction, :payment_items).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    
    data
  end

  def template
    "payment_tax_report"
  end
end
