class ShippingInstructionHistory < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
		assoc.belongs_to :shipping_instruction
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

	# def vessels
	# 	self.shipping_instruction.vessels
	# end

	# def si_containers
	# 	self.shipping_instruction.si_containers
	# end

	def populate_data(si)
		self.shipping_instruction_id = si.id
		self.si_no = si.si_no
		self.shipper_id = si.shipper_id
		self.consignee_id = si.consignee_id
		self.shipper_name = si.shipper_name
		self.consignee_name = si.consignee_name
		self.notify_party = si.notify_party
		self.country_of_origin = si.country_of_origin
		self.carrier = si.carrier
		self.pic = si.pic
		self.feeder_vessel = si.feeder_vessel
		self.connection_vessel = si.connection_vessel
		self.place_of_receipt = si.place_of_receipt
		self.port_of_loading = si.port_of_loading
		self.port_of_transhipment = si.port_of_transhipment
		self.port_of_discharge = si.port_of_discharge
		self.final_destination = si.final_destination
		self.no_of_obl = si.no_of_obl
		self.si_date = si.si_date
		self.marks_no = si.marks_no
		self.description_packages = si.description_packages
		self.gw = si.gw
		self.nw = si.nw
		self.measurement = si.measurement
		self.dimension = si.dimension
		self.freight = si.freight
		self.freight_details = si.freight_details
		self.special_instructions = si.special_instructions
		self.container_no = si.container_no
		self.container_no_2 = si.container_no_2
		self.peb_no = si.peb_no
		self.inst_date = si.inst_date
		self.kpbc = si.kpbc
		self.hs_code = si.hs_code
		self.create_by = si.create_by
		self.update_by = si.update_by
		self.shipper_reference = si.shipper_reference
		self.status = si.status
		self.order_type = si.order_type
		self.booking_no = si.booking_no
		self.created_at = si.created_at
		self.updated_at = si.updated_at
		# Revisi 1 Dec 2015
		self.trade = si.trade
		self.handle_by = si.handle_by

		self.master_bl_no = si.master_bl_no
		self.volume = si.volume
		self.shipping_schedule = si.shipping_schedule
		# self.vessels = si.volume
		# self.si_containers = si.shipping_schedule
		self.is_cancel = si.is_cancel
		self.order_details = si.order_details
		self.is_shadow = si.is_shadow
	end

	# def volume
	# 	self.vessels.blank? ? self.shipping_instruction.volume : self.vessels
	# end

	# def shipping_schedule
	# 	self.si_containers.blank? ? self.shipping_instruction.shipping_schedule : self.si_containers
	# end
end
