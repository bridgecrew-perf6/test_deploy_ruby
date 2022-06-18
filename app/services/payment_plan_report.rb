class PaymentPlanReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns, :row_ref_ids
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format, :row_ref_ids
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
  	tmp = "Payments Plan"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Payments Plan"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  def populate_data
    row_ids = self.row_ids
    row_ref_ids = self.row_ref_ids
    ref_length = self.row_ref_ids.select(&:presence).length

    data = []
    if ref_length < row_ref_ids.length
      row_ids.each_with_index do |row, index|
        si = ShippingInstruction.find(row)
        if row_ref_ids[index].blank?
          data.push PaymentInvoice.new(shipping_instruction: si)
        else
          data.push PaymentInvoice.find(row_ref_ids[index])
        end
      end
    else
      data = PaymentInvoice.includes(:shipping_instruction, :payment_items).where(id: row_ref_ids).order("FIELD(id, #{row_ref_ids.join(',')})")
    end
    data
  end

  def template
    "payment_plan_report"
  end
end
