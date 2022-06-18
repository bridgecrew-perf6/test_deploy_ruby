class CostRevenueItem < ActiveRecord::Base
	include UpcaseAttributes

	enum item_type: [ :fixed, :active, :volume, :shipper, :carrier ]

	attr_accessor :_destroy
	belongs_to :cost_revenue, touch: true

	delegate :selling_rate, :buying_rate, to: :cost_revenue, allow_nil: true
	
	def profit_usd
		unless self.new_record?
		self.selling_usd - self.buying_usd unless self.selling_usd.nil? && self.buying_usd.nil?
		end
	end

	def profit_idr
		unless self.new_record?
			self.selling_idr - self.buying_idr unless self.selling_idr.nil? && self.buying_idr.nil?
		end
	end

	def selling_total
		if self.selling_usd.to_f != 0
			rate = (self.selling_rate.to_f == 0) ? 1 : self.selling_rate.to_f
			(self.selling_volume.to_f * self.selling_usd.to_f * rate).round(2)
		elsif self.selling_idr.to_f != 0
			(self.selling_volume.to_f * self.selling_idr.to_f).round(2)
		end
	end

	# def selling_total_after_tax
	# end

	def buying_total
		if self.buying_usd.to_f != 0
			rate = (self.buying_rate.to_f == 0) ? 1 : self.buying_rate.to_f
			(self.buying_volume.to_f * self.buying_usd.to_f * rate).round(2)
		elsif self.buying_idr.to_f != 0
			(self.buying_volume.to_f * self.buying_idr.to_f).round(2)
		end
	end

	# def buying_total_after_tax
	# end
end
