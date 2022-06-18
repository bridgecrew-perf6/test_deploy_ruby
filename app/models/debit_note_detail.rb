class DebitNoteDetail < ActiveRecord::Base
  include UpcaseAttributes

	# attr_accessor :_destroy, :default_amount
	attr_accessor :_destroy
	belongs_to :debit_note, touch: true, inverse_of: :invoice_details
	
	delegate :rate, :currency_code, to: :debit_note, allow_nil: true  
	
	def subtotal
		return if self._destroy == 1
		total = self.amount.to_f * self.volume.to_f
		# if self.currency_code == "USD" && self.rate.to_f != 0
		# 	total /= self.rate.to_f
		# end
		total.round(2)
	end

end
