class PaymentCloseDeposit < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc| 
    assoc.belongs_to :carrier
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  end

  validates_presence_of :carrier, :shipping_instruction, :payment_type, :payment_date, :amount

  def currency
  	self.payment_type
  end

  def master_bl_no
  	self.shipping_instruction.master_bl_no
  end
end
