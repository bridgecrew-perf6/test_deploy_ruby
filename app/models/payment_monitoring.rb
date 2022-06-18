class PaymentMonitoring < ActiveRecord::Base # Outstanding Payment
  belongs_to :shipping_instruction
  # has_one :bill_of_lading, through: :shipping_instruction

  # def hbl_no_and_carrier
  # def actual_name
  #   # "#{hbl_no} / #{carrier}"
  #   self.name
  # end

  # def bill_of_lading_id
  #   self.bill_of_lading.id
  # end

  def carrier
  	self.shipping_instruction.try(:carrier)
  end
end
