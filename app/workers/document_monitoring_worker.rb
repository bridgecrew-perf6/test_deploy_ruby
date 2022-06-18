class DocumentMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :document_monitoring

  def perform(shipping_instruction_id)
    self.class.process_document_monitoring(shipping_instruction_id)
  end

  private
  def self.process_document_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   document_monitoring = DocumentMonitoring.find_by(shipping_instruction_id: shipping_instruction.id)
      
    #   unless shipping_instruction.first_etd_date.blank?
    #     if ((shipping_instruction.first_etd_date + 1.day) >= DateTime.now.in_time_zone("Jakarta").to_date)
    #       bill_of_lading = BillOfLading.find_by(shipping_instruction_id: shipping_instruction.id)
          
    #       if !bill_of_lading.blank? && !bill_of_lading.delivery_doc
    #         if document_monitoring.blank?
    #           DocumentMonitoring.create(bill_of_lading_id: bill_of_lading.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, shipper_company_name: bill_of_lading.shipper_company_name, etd_date: shipping_instruction.first_etd_date)
    #         else
    #           document_monitoring.update(bill_of_lading_id: bill_of_lading.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, shipper_company_name: bill_of_lading.shipper_company_name, etd_date: shipping_instruction.first_etd_date)
    #         end
    #         return
    #       end
    #     end
    #   end
    #   document_monitoring.try(:destroy)
    # end


    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   unless si.bill_of_lading.blank?
    #     etd_date = si.first_etd_date

    #     unless etd_date.blank?
    #       if (etd_date + 1.day) >= DateTime.now.in_time_zone("Jakarta").to_date
    #         bl = BillOfLading.find_by(shipping_instruction_id: shipping_instruction_id)
            
    #         unless bl.delivery_doc
    #           monitoring = DocumentMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
    #           unless monitoring.blank?
    #             monitoring.update(bill_of_lading_id: bl.id, shipping_instruction_id: shipping_instruction_id,
    #                               ibl_ref: si.ibl_ref, shipper_company_name: bl.shipper_company_name, etd_date: etd_date)                
    #           else
    #             DocumentMonitoring.create(bill_of_lading_id: bl.id, shipping_instruction_id: shipping_instruction_id,
    #                               ibl_ref: si.ibl_ref, shipper_company_name: bl.shipper_company_name, etd_date: etd_date)
    #           end
    #           return
    #         end
    #       end
    #     end
    #   end
    #   DocumentMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    # end


    si = ShippingInstruction.find(shipping_instruction_id)
    if si.has_outstanding_document?
      bl = si.bill_of_lading
      name = "#{bl.ibl_ref} / #{bl.shipper_company_name} / #{bl.carrier}"
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date
    
      monitoring = DocumentMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        # monitoring.update(bill_of_lading_id: bl.id, shipping_instruction_id: shipping_instruction_id,
        #                   ibl_ref: si.ibl_ref, shipper_company_name: bl.shipper_company_name, etd_date: etd_date)                
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)                
      else
        # DocumentMonitoring.create(bill_of_lading_id: bl.id, shipping_instruction_id: shipping_instruction_id,
        #                   ibl_ref: si.ibl_ref, shipper_company_name: bl.shipper_company_name, etd_date: etd_date)
        DocumentMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      DocumentMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
