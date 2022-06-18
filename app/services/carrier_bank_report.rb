class CarrierBankReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns
  attr_accessor :format, :monthly, :from, :to

  # validates_presence_of :row_ids, :columns, :format
  validates_presence_of :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Carrier Banks"
    tmp.upcase
  end

  def title
    tmp = "Carrier Banks"
    tmp.upcase
  end

  def populate_data
    params = {}
    data = CarrierBank.search(params)
    data
  end

  def template
    "carrier_bank_report"
  end
end
