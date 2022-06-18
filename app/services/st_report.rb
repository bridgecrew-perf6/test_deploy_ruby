class StReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Shipments Tracking"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Shipments Tracking"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  def populate_data
    row_ids = self.row_ids

    data = []

    data = ShipmentTracking.includes(shipping_instruction: [ :shipper, :vessels ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    
    data
  end

  def template
    "st_report"
  end
end
