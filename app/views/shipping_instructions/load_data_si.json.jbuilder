json.extract! @shipping_instruction, :id, :final_destination, :si_no, :shipper_reference
json.shipper do
	json.company_name @shipping_instruction.shipper_company_name
end
json.bill_of_landing do
	json.bl_number @shipping_instruction.bill_of_lading.master_bl_no.blank? ? @shipping_instruction.bill_of_lading.bl_number : @shipping_instruction.bill_of_lading.master_bl_no
end
json.vessel do
	json.vessel_name @shipping_instruction.vessels.first.vessel_name
	json.etd_date normal_date_format(@shipping_instruction.vessels.first.etd_date)
end
json.volume @volume.join(" & ")