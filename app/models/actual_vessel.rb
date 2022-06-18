class ActualVessel < ActiveRecord::Base
	with_options touch: true do |assoc|
		assoc.belongs_to :shipment_tracking
		assoc.belongs_to :vessel
	end

  scope :get_row, -> (id) {
    includes({shipment_tracking: [:shipping_instruction, {actual_vessels: [:vessel]}]}, :vessel)
    .references({shipment_tracking: [:shipping_instruction, {actual_vessels: [:vessel]}]}, :vessel)
    .where(id: id).first
  }

	# STATUS FREE TIME
	ESTIMATE 	= 0.freeze
	CONFIRM 	= 1.freeze
	DELAY		= 2.freeze
	SWITCH		= 3.freeze
	OTHERS		= 4.freeze

	%w(ESTIMATE CONFIRM DELAY SWITCH OTHERS).each do |state|
		define_method "#{state.downcase}?" do
			free_status == self.class.const_get(state)
		end
	end

	def status_actual_vessel
		if self.estimate?
			return "Estimate"
		elsif self.confirm?
			return "Confirm"
		elsif self.delay?
			return "Delay"
		elsif self.switch?
			return "Switch"
		elsif self.others?
			return "Others"
		end
	end
end
