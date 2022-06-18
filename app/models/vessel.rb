class Vessel < ActiveRecord::Base
  include UpcaseAttributes

	belongs_to :shipping_instruction, :inverse_of => :vessels, touch: true
	has_one :actual_vessel, :dependent => :destroy
	validates_presence_of :vessel_name
	# validates_presence_of :etd_date, :message => "can't be blank"
end
