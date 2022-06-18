class UserReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns
  attr_accessor :format, :monthly, :from, :to

  # validates_presence_of :row_ids, :columns, :format
  validates_presence_of :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Users"
    tmp.upcase
  end

  def title
    tmp = "Users"
    tmp.upcase
  end

  def populate_data
    data = User.order(:username)
    data
  end

  def template
    "user_report"
  end
end
