class BlReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
  	tmp = "Bill of Ladings"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Bill of Ladings"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  def populate_data
    row_ids = self.row_ids

    data = []

    data = BillOfLading.includes(:invoices, :shipper, :consignee, :debit_notes, :notes, :payments, shipping_instruction: [ :vessels, si_containers: [ :container ] ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    
    data
  end

  def template
    "bl_report"
  end
end
