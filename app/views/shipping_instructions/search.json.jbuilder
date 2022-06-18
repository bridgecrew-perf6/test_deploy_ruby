data = Array.new
@shipping_instructions.each do |row|
  row_data = Rails.cache.fetch "shipping_instruction_row_#{row.id}_#{row.updated_at.to_i}" do
    actions = link_to '<i class="icon-eye-open icon-large"></i>'.html_safe, row, title: "Show Shipping Instruction"
    actions += link_to '<i class="icon-edit-sign icon-large"></i>'.html_safe, edit_shipping_instruction_path(row),
                       title: "Edit Shipping Instruction" if row.is_uncanceled? && row.is_open?
    if row.is_uncanceled? && row.is_open?
      unless row.is_shadow
        actions += '<div>'.html_safe
        if row.bill_of_lading.nil?
          actions += link_to 'Create BL', '/createBL/' + row.id.to_s, data: {confirm: "Already update SI data?"}
        else
          actions += link_to 'Update BL', edit_bill_of_lading_path(row.bill_of_lading)
        end
        actions += "</div>".html_safe
      end
      actions += '<div>'.html_safe + link_to('Cancel SI', cancel_shipping_instruction_path(row), data: {confirm: 'Are you sure?'}) + '</div>'.html_safe
    elsif row.is_canceled?
      actions += '<div>'.html_safe + link_to('Uncancel SI', uncancel_shipping_instruction_path(row), data: {confirm: 'Are you sure?'}) + '</div>'.html_safe
    end

    ibl_si_no = row.si_no
    ibl_si_no += '<span class="label label-warning">Cancel</span>'.html_safe if row.is_canceled?
    ibl_si_no += '<span class="label">Closed</span>'.html_safe if row.is_closed?

    shipper = '<pre class="free">'.html_safe
    shipper += row.shipper_company_name
    shipper += '</pre>&nbsp;'.html_safe

    containers = row.si_containers.map { |c| (c.container.container_type == "LCL" ?
      "#{number_with_precision(c.volum, precision: 3, delimiter: ',')} M3 #{c.container.container_type}" :
      "#{c.volum}x#{c.container.container_type}") }.join(" & ")

    [actions, ibl_si_no, row.shipper_reference.to_s + "&nbsp;".html_safe, shipper, containers,
     row.final_destination.to_s + "&nbsp;".html_safe, si_date_format(row.first_etd_date).to_s + "&nbsp;".html_safe,
     si_date_format(row.si_date).to_s + "&nbsp;".html_safe, row.carrier, row.consignee_company_name,
     row.first_line_notify_party, row.port_of_loading, row.booking_no,
     row.master_bl_no, row.order_type_text]
  end

  data.push row_data
end

json.draw params[:draw]
json.recordsTotal ShippingInstruction.count
json.recordsFiltered ShippingInstruction.count
json.data do
  json.array! data
end