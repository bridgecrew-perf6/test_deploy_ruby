class Region < ActiveRecord::Base
  include UpcaseAttributes

	has_many :countries
end
