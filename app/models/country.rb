class Country < ActiveRecord::Base
  include UpcaseAttributes

	belongs_to :region, touch: true
	# has_many :consignees
	# has_many :shippers
end
