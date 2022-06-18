class BillOfLadingHistory < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
		assoc.belongs_to :shipping_instruction
		assoc.belongs_to :bill_of_lading
		assoc.belongs_to :shipper
		assoc.belongs_to :consignee
	end
	
	# def shipper_name
	# 	unless self.shipper_id.nil?
	# 		# address_custom_fields = self.shipper.custom_fields.where(:field_key => "address") unless self.shipper_id.nil?
	# 		shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
	# 		# shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
	# 		shipper_name += self.shipper.full_address unless self.shipper_id.nil?	
	# 	end
	# end

	# def consignee_name
	# 	unless self.consignee_id.nil?
	# 		consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
	# 		consignee_name += self.consignee.full_address unless self.consignee_id.nil?
	# 	end
	# end

	def normal_date_format(date_str)
		date_str.to_time.strftime('%d %B %Y') unless date_str.nil?
	end

	def update_shipper_name
		unless self.shipper_id.nil?
			# address_custom_fields = self.shipper.custom_fields.where(:field_key => "address") unless self.shipper_id.nil?
			tmp_shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
			# shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
			tmp_shipper_name += self.shipper.full_address unless self.shipper_id.nil?	
			self.shipper_name = tmp_shipper_name
		end
	end

	def update_consignee_name
		unless self.consignee_id.nil?
			tmp_consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
			tmp_consignee_name += self.consignee.full_address unless self.consignee_id.nil?
			self.consignee_name = tmp_consignee_name
		end
	end
	
	def populate_data(bl)
		self.bill_of_lading_id = bl.id
		self.shipping_instruction_id = bl.shipping_instruction_id
		self.shipper_id = bl.shipper_id
		self.consignee_id = bl.consignee_id
		self.shipper_name = bl.shipper_name
		self.consignee_name = bl.consignee_name
		self.notify_party = bl.notify_party
		self.country_of_origin = bl.country_of_origin
		self.also_notify_party = bl.also_notify_party
		self.place_of_receipt = bl.place_of_receipt
		self.port_of_loading = bl.port_of_loading
		self.port_of_discharge = bl.port_of_discharge
		self.final_destination = bl.final_destination
		self.feeder_vessel = bl.feeder_vessel
		self.connection_vessel = bl.connection_vessel
		self.marks_no = bl.marks_no
		self.description_packages = bl.description_packages
		self.gw = bl.gw
		self.measurement = bl.measurement
		self.container_no = bl.container_no
		self.freight = bl.freight
		self.freight_details = bl.freight_details
		self.no_of_obl = bl.no_of_obl
		self.date_of_issue = bl.date_of_issue
		self.shipped_on_board = bl.shipped_on_board
		self.create_by = bl.create_by
		self.update_by = bl.update_by
		self.bl_number = bl.bl_number
		self.place_of_issue = bl.place_of_issue
		self.special_clause = bl.special_clause
		self.master_bl_no = bl.master_bl_no
		self.created_at = bl.created_at
		self.updated_at = bl.updated_at
	end
end
