class BlMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :bl_monitoring

  # def perform(bill_of_lading_id)
  #   self.class.process_bl_monitoring(bill_of_lading_id)
  # end

  def perform(shipping_instruction_id)
    self.class.process_bl_monitoring(shipping_instruction_id)
  end

  private
  # def self.process_bl_monitoring(bill_of_lading_id)
  #   # bill_of_lading = BillOfLading.find(bill_of_lading_id)
  #   #
  #   # hbl_no = bill_of_lading.bl_number.presence || bill_of_lading.shipping_instruction.si_no
  #   # mbl_no = bill_of_lading.master_bl_no.presence || bill_of_lading.shipping_instruction.master_bl_no
  #   # vessel = bill_of_lading.shipping_instruction.vessels.first
  #   #
  #   # if bl_monitoring = BlMonitoring.find_by(bill_of_lading: bill_of_lading)
  #   #   bl_monitoring.update(bill_of_lading: bill_of_lading, hbl_no: hbl_no, mbl_no: mbl_no, shipment_date: vessel.etd_date)
  #   # else
  #   #   bl_monitoring = BlMonitoring.create(bill_of_lading: bill_of_lading, hbl_no: hbl_no, mbl_no: mbl_no, shipment_date: vessel.etd_date)
  #   # end
  #   #
  #   # invoices = bill_of_lading.invoices.uncanceled
  #   # debit_notes = bill_of_lading.debit_notes.uncanceled
  #   # notes = bill_of_lading.notes.uncanceled
  #   # invoices_count = (invoices.count + debit_notes.count + notes.count)
  #   # closed_invoices_count = (invoices.closed.count + debit_notes.closed.count + notes.closed.count)
  #   #
  #   # if invoices_count == 0
  #   #   bl_monitoring.update(invoiced: false, closed: true)
  #   # elsif invoices_count > 0
  #   #   bl_monitoring.update(invoiced: true, closed: false)
  #   #
  #   #   if invoices_count == closed_invoices_count
  #   #     bl_monitoring.update(closed: true)
  #   #     CostRevenue.find_or_create_by(shipping_instruction: bill_of_lading.shipping_instruction)
  #   #   end
  #   # end

  #   # Revisi 18 May 2015
  #   if bill_of_lading = BillOfLading.find(bill_of_lading_id)
  #     invoices = bill_of_lading.invoices.uncanceled.count
  #     debit_notes = bill_of_lading.debit_notes.uncanceled.count
  #     notes = bill_of_lading.notes.uncanceled.count

  #     invoices_count = invoices + debit_notes + notes

  #     if invoices_count > 0
  #       BlMonitoring.where(bill_of_lading_id: bill_of_lading.id).destroy_all
  #     else
  #       hbl_no = bill_of_lading.bl_number.presence || bill_of_lading.shipping_instruction.si_no
  #       shipping_instruction = bill_of_lading.shipping_instruction

  #       if bill_of_lading.shipper_id == shipping_instruction.shipper_id
  #         shipper = bill_of_lading.shipper
  #       else
  #         if bill_of_lading.updated_at >= shipping_instruction.updated_at
  #           shipper = bill_of_lading.shipper
  #         else
  #           shipper = shipping_instruction.shipper
  #         end
  #       end

  #       first_vessel = bill_of_lading.shipping_instruction.vessels.first

  #       if monitoring = BlMonitoring.find_by(bill_of_lading_id: bill_of_lading.id)
  #         if first_vessel && shipper
  #           monitoring.update(bill_of_lading_id: bill_of_lading.id, hbl_no: hbl_no, mbl_no: shipper.company_name, shipment_date: first_vessel.etd_date)
  #         end
  #       else
  #         if first_vessel && shipper
  #           BlMonitoring.create(bill_of_lading_id: bill_of_lading.id, hbl_no: hbl_no, mbl_no: shipper.company_name, shipment_date: first_vessel.etd_date)
  #         end
  #       end
  #     end
  #   else
  #     BlMonitoring.where(bill_of_lading_id: bill_of_lading_id).destroy_all
  #   end
  # end

  def self.process_bl_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   bill_of_lading = shipping_instruction.bill_of_lading
      
    #   unless bill_of_lading.blank?
    #     invoices = bill_of_lading.invoices.uncanceled.count
    #     debit_notes = bill_of_lading.debit_notes.uncanceled.count
    #     notes = bill_of_lading.notes.uncanceled.count

    #     invoice_count = invoices + debit_notes + notes

    #     if invoice_count > 0
    #       BlMonitoring.where(bill_of_lading_id: bill_of_lading.id).destroy_all
    #     else
    #       ibl_ref = shipping_instruction.ibl_ref
          
    #       if bill_of_lading.shipper_id == shipping_instruction.shipper_id
    #         shipper = bill_of_lading.shipper
    #       else
    #         if bill_of_lading.updated_at >= shipping_instruction.updated_at
    #           shipper = bill_of_lading.shipper
    #         else
    #           shipper = shipping_instruction.shipper
    #         end
    #       end

    #       first_vessel = shipping_instruction.vessels.first
          
    #       bl_monitoring = BlMonitoring.find_by(bill_of_lading_id: bill_of_lading.id)

    #       if !first_vessel.blank? && !shipper.blank?
    #         if bl_monitoring.blank?
    #           BlMonitoring.create(bill_of_lading_id: bill_of_lading.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: first_vessel.etd_date)
    #         else
    #           bl_monitoring.update(bill_of_lading_id: bill_of_lading.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: first_vessel.etd_date)
    #         end
    #       end
    #     end
    #   end
    # end

    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   bl = si.bill_of_lading
      
    #   unless bl.blank?
    #     inv = bl.invoices.uncanceled.count
    #     dbn = bl.debit_notes.uncanceled.count
    #     crn = bl.notes.uncanceled.count
    #     invoice_count = inv + dbn + crn

    #     if invoice_count > 0
    #       BlMonitoring.where(bill_of_lading_id: bl.id).destroy_all
    #     else
    #       ibl_ref = si.ibl_ref
          
    #       if bl.shipper_id == si.shipper_id
    #         shipper = bl.shipper
    #       else
    #         if bl.updated_at >= si.updated_at
    #           shipper = bl.shipper
    #         else
    #           shipper = si.shipper
    #         end
    #       end

    #       first_vessel = si.vessels.first
          
    #       if !first_vessel.blank? && !shipper.blank?
    #         monitoring = BlMonitoring.find_by(bill_of_lading_id: bl.id)
    #         etd_date = si.first_etd_date
            
    #         unless monitoring.blank?
    #           monitoring.update(bill_of_lading_id: bl.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: etd_date)
    #         else
    #           BlMonitoring.create(bill_of_lading_id: bl.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: etd_date)
    #         end
    #         return
    #       end
    #     end
    #   end
    # end
    # BlMonitoring.where(bill_of_lading_id: si.bill_of_lading.id).destroy_all


    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   bl = si.bill_of_lading
      
    #   unless bl.blank?
    #     inv = bl.invoices.uncanceled.count
    #     dbn = bl.debit_notes.uncanceled.count
    #     crn = bl.notes.uncanceled.count
    #     invoice_count = inv + dbn + crn

    #     if invoice_count > 0
    #       BlMonitoring.where(bill_of_lading_id: bl.id).destroy_all
    #     else
    #       ibl_ref = si.ibl_ref
          
    #       if bl.shipper_id == si.shipper_id
    #         shipper = bl.shipper
    #       else
    #         if bl.updated_at >= si.updated_at
    #           shipper = bl.shipper
    #         else
    #           shipper = si.shipper
    #         end
    #       end

    #       first_vessel = si.vessels.first
          
    #       if !first_vessel.blank? && !shipper.blank?
    #         monitoring = BlMonitoring.find_by(bill_of_lading_id: bl.id)
    #         etd_date = si.first_etd_date
            
    #         unless monitoring.blank?
    #           monitoring.update(bill_of_lading_id: bl.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: etd_date)
    #         else
    #           BlMonitoring.create(bill_of_lading_id: bl.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: etd_date)
    #         end
    #         return
    #       end
    #     end
    #   end
    # end
    # BlMonitoring.where(bill_of_lading_id: si.bill_of_lading.id).destroy_all
    
    si = ShippingInstruction.find(shipping_instruction_id)
    # bl = si.bill_of_lading
    if si.has_outstanding_invoicing?  
      # name = "#{bl.ibl_ref} / #{bl.shipper_company_name.blank? ? '-- MBL # --' : bl.shipper_company_name}"
      name = "#{si.ibl_ref} / #{si.shipper_company_name}"
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date
        
      # monitoring = BlMonitoring.find_by(bill_of_lading_id: bl.id)
      monitoring = BlMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        # monitoring.update(bill_of_lading_id: bl.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: etd_date)
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      else
        # BlMonitoring.create(bill_of_lading_id: bl.id, hbl_no: ibl_ref, mbl_no: shipper.company_name, shipment_date: etd_date)
        BlMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      # BlMonitoring.where(bill_of_lading_id: bl.try(:id)).destroy_all
      BlMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
