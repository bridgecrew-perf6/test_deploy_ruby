class InvoiceDetail < ActiveRecord::Base
  include UpcaseAttributes

  enum item_type: [ :fixed, :active, :volume, :shipper, :carrier ]

	# attr_accessor :_destroy, :default_amount
	attr_accessor :_destroy
	belongs_to :invoice, touch: true, inverse_of: :invoice_details
	
	delegate :rate, :currency_code, to: :invoice, allow_nil: true  
	
	def subtotal
		return if self._destroy == 1
		total = self.amount.to_f * self.volume.to_f
		# if self.currency_code == "IDR" && self.rate.to_f != 0
		# 	total *= self.rate.to_f
		# end
		
		# if self.currency_code == "USD" && self.rate.to_f != 0
		# 	total /= self.rate.to_f
		# end
		total.round(2)
	end

end