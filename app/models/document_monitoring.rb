class DocumentMonitoring < ActiveRecord::Base # Outstanding Document
  # belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  belongs_to :shipping_instruction
  has_one :bill_of_lading, through: :shipping_instruction
  
  # def actual_name
  #   # "#{self.shipping_instruction.ibl_ref} / #{self.bill_of_lading.shipper_company_name}"
  # 	self.name
  # end

  def bill_of_lading_id
  	self.bill_of_lading.try(:id)
  end
end
