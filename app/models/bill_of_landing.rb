class BillOfLanding < ActiveRecord::Base
	attr_accessor :shipper_name, :consignee_name, :shipper_reference

	belongs_to :shipper
	belongs_to :consignee
	belongs_to :shipping_instruction
	has_many :invoices

	def shipper_name
		address_custom_fields = self.shipper.custom_fields.where(:field_key => "address")
		shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
		shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
		#shipper_name += self.shipper.full_address.sub! '<br/>', "\n" unless self.shipper_id.nil?
	end

	def consignee_name
		consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
		consignee_name += self.consignee.full_address.sub! '<br/>', "\n" unless self.consignee_id.nil?
	end
end
