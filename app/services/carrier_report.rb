class CarrierReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns
  attr_accessor :format, :monthly, :from, :to

  # validates_presence_of :row_ids, :columns, :format
  validates_presence_of :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Carriers"
    tmp.upcase
  end

  def title
    tmp = "Carriers"
    tmp.upcase
  end

  def populate_data
    data = Carrier.with_custom_fields
    data
  end

  def template
    "carrier_report"
  end
end
