class SiReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
  	tmp = "Shipping Instructions"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Shipping Instructions"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.to.blank?
    # tmp += self.from.blank? ? "#{Date.parse(self.monthly).at_beginning_of_year}" : " #{Date.parse(self.from)}"
    # tmp += " s/d "
    # tmp += self.to.blank? ? "#{Date.parse(self.monthly)}" : " #{Date.parse(self.to)}"
    tmp.upcase
  end

  def populate_data
    row_ids = self.row_ids

    data = []

    data = ShippingInstruction.includes(:shipper, :consignee, :vessels, :handler, :bill_of_lading, :cost_revenue, si_containers: [ :container ]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    
    data
  end

  def template
    "si_report"
  end
end
