class CostRevenueCoverReport
  include ActiveModel::Model
  include ActiveModel::Validations

  # mattr_accessor :row_ids, :columns, :id
  attr_accessor :filename, :format, :populate_data

  validates_presence_of :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  # def filename
  # 	# tmp = ""
  #  #  tmp.upcase
  # end

  # def title
  #   # tmp = ""
  #   # tmp.upcase
  # end

  # def populate_data
  # end

  def template
    "cost_revenue_selling_buying_report"
  end
end
