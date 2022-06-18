class SiMonitoring < ActiveRecord::Base # Outstanding SI
  belongs_to :shipping_instruction
  # has_one :bill_of_lading, through: :shipping_instruction

  # default_scope -> { where(hidden: false) }

  # def actual_name
  # 	# "#{self.shipping_instruction.ibl_ref} / #{self.shipping_instruction.author_name}"
  # 	self.name
  # end

  # def bill_of_lading_id
  #   self.bill_of_lading.id
  # end
end
