# require 'logger'
class InvoiceMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :invoice_monitoring

  def perform(shipping_instruction_id)
    self.class.process_invoice_monitoring(shipping_instruction_id)
  end

  private
  def self.process_invoice_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   bill_of_lading = BillOfLading.find_by(shipping_instruction_id: shipping_instruction_id)
      
    #   unless bill_of_lading.blank?
    #     Invoice.where(bill_of_lading_id: bill_of_lading.id).each do |invoice|
    #       invoice_monitoring = InvoiceMonitoring.find_by(shipping_instruction_id: shipping_instruction.id, invoice_id: invoice.id)
    #       if !invoice.due_date.blank? && ((invoice.due_date + 3.days) >= DateTime.now.in_time_zone("Jakarta").to_date) && invoice.status_payment == 0
    #         if invoice_monitoring.blank?
    #           InvoiceMonitoring.create(invoice_id: invoice.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, invoice_no: invoice.invoice_no, shipper_company_name: shipping_instruction.shipper_company_name, etd_date: invoice.etd)
    #         else
    #           invoice_monitoring.update(invoice_id: invoice.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, invoice_no: invoice.invoice_no, shipper_company_name: shipping_instruction.shipper_company_name, etd_date: invoice.etd)
    #         end
    #       else
    #         invoice_monitoring.try(:destroy)
    #       end
    #     end

    #     DebitNote.where(bill_of_lading_id: bill_of_lading.id).each do |invoice|
    #       invoice_monitoring = InvoiceMonitoring.find_by(shipping_instruction_id: shipping_instruction.id, debit_note_id: invoice.id)
    #       if !invoice.due_date.blank? && ((invoice.due_date + 3.days) <= DateTime.now.in_time_zone("Jakarta").to_date) && invoice.status_payment == 0
    #         if invoice_monitoring.blank?
    #           InvoiceMonitoring.create(debit_note_id: invoice.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, invoice_no: invoice.invoice_no, shipper_company_name: shipping_instruction.shipper_company_name, etd_date: invoice.etd)
    #         else
    #           invoice_monitoring.update(debit_note_id: invoice.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, invoice_no: invoice.invoice_no, shipper_company_name: shipping_instruction.shipper_company_name, etd_date: invoice.etd)
    #         end
    #       else
    #         invoice_monitoring.try(:destroy)
    #       end
    #     end

    #     Note.where(bill_of_lading_id: bill_of_lading.id).each do |invoice|
    #       invoice_monitoring = InvoiceMonitoring.find_by(shipping_instruction_id: shipping_instruction.id, note_id: invoice.id)
    #       if !invoice.due_date.blank? && ((invoice.due_date + 3.days) <= DateTime.now.in_time_zone("Jakarta").to_date) && invoice.status_payment == 0
    #         if invoice_monitoring.blank?
    #           InvoiceMonitoring.create(note_id: invoice.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, invoice_no: invoice.invoice_no, shipper_company_name: shipping_instruction.shipper_company_name, etd_date: invoice.etd)
    #         else
    #           invoice_monitoring.update(note_id: invoice.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             ibl_ref: shipping_instruction.si_no, invoice_no: invoice.invoice_no, shipper_company_name: shipping_instruction.shipper_company_name, etd_date: invoice.etd)
    #         end
    #       else
    #         invoice_monitoring.try(:destroy)
    #       end
    #     end

    #     return
    #   end

    #   # invoice_monitoring = InvoiceMonitoring.find_by(shipping_instruction_id: shipping_instruction.id).where.not(invoice_id: nil)
    #   invoice_monitoring = InvoiceMonitoring.where(shipping_instruction_id: shipping_instruction.id)
    #   invoice_monitoring.destroy_all unless invoice_monitoring.blank?
    # end

    # # logger = Logger.new('logfile.log')
    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   bl = si.bill_of_lading
      
    #   unless bl.blank?
    #     invoices = bl.invoices + bl.debit_notes + bl.notes

    #     invoices.each do |invoice|
    #       # params = {shipping_instruction_id: shipping_instruction_id}
    #       # params[:invoice_id] = invoice.id if invoice.kind_of? Invoice
    #       # params[:debit_note_id] = invoice.id if invoice.kind_of? DebitNote
    #       # params[:note_id] = invoice.id if invoice.kind_of? Note
    #       # # params_uniq = params

    #       # params_uniq = {shipping_instruction_id: shipping_instruction_id}
    #       # params_uniq[:invoice_id] = invoice.id if invoice.kind_of? Invoice
    #       # params_uniq[:debit_note_id] = invoice.id if invoice.kind_of? DebitNote
    #       # params_uniq[:note_id] = invoice.id if invoice.kind_of? Note

    #       if invoice.kind_of? Invoice
    #         params_uniq = {shipping_instruction_id: shipping_instruction_id, invoice_id: invoice.id}
    #         params = {shipping_instruction_id: shipping_instruction_id, invoice_id: invoice.id}
    #       elsif invoice.kind_of? DebitNote 
    #         params_uniq = {shipping_instruction_id: shipping_instruction_id, debit_note_id: invoice.id}
    #         params = {shipping_instruction_id: shipping_instruction_id, debit_note_id: invoice.id}
    #       elsif invoice.kind_of? Note
    #         params_uniq = {shipping_instruction_id: shipping_instruction_id, note_id: invoice.id}
    #         params = {shipping_instruction_id: shipping_instruction_id, note_id: invoice.id}
    #       end

    #       monitoring = InvoiceMonitoring.find_by(params_uniq)
    #       unless invoice.due_date.blank?
    #         # if ((invoice.due_date + 3.days) <= DateTime.now.in_time_zone("Jakarta").to_date) && invoice.status_payment == 0
    #         if ((invoice.due_date + 3.days) <= DateTime.now.in_time_zone("Jakarta").to_date) && invoice.is_payment_open? && invoice.is_uncanceled?
    #           # name = "#{si.shipper_company_name} / #{si.ibl_ref}"
    #           name = "#{invoice.to_shipper} / #{invoice.invoice_no}"
    #           ibl_ref = si.ibl_ref
    #           etd_date = invoice.etd

    #           params[:name] = name
    #           params[:ibl_ref] = ibl_ref
    #           params[:etd_date] = etd_date

    #           # puts "1. Init Invoice #{invoice.invoice_no} : #{params_uniq}"
    #           # puts "2. Init Invoice #{invoice.invoice_no} : #{params}"
    #           # logger.info "1. Init Invoice #{invoice.invoice_no} : #{params_uniq}"
    #           # monitoring = InvoiceMonitoring.find_by(params_uniq)
    #           unless monitoring.blank?
    #             logger.info "Update List Due Date Invoice #{name}"
    #             monitoring.update(params)
    #           else
    #             logger.info "Create List Due Date Invoice #{name}"
    #             InvoiceMonitoring.create(params)
    #           end
    #         else
    #           # # puts "1. Destroy Invoice #{invoice.invoice_no} : #{params_uniq}"
    #           # logger.info "1. Destroy List Due Date Invoice #{invoice.invoice_no}" unless monitoring.blank?
    #           # # InvoiceMonitoring.where(params_uniq).destroy_all
    #           # monitoring.try(:destroy)
    #           InvoiceMonitoring.where(params_uniq).destroy_all
    #         end
    #       else
    #         # # puts "2. Destroy Invoice #{invoice.invoice_no} : #{params_uniq}"
    #         # logger.info "2. Destroy List Due Date Invoice #{invoice.invoice_no}" unless monitoring.blank?
    #         # # InvoiceMonitoring.where(params_uniq).destroy_all
    #         # monitoring.try(:destroy)
    #         InvoiceMonitoring.where(params_uniq).destroy_all
    #       end
    #     end
    #   end
    # end


    si = ShippingInstruction.find(shipping_instruction_id)
    unless si.blank?
      bl = si.bill_of_lading
      
      unless bl.blank?
        invoices = bl.invoices + bl.debit_notes + bl.notes

        invoices.each do |invoice|
          if invoice.kind_of? Invoice
            params_uniq = {shipping_instruction_id: shipping_instruction_id, invoice_id: invoice.id}
            params = {shipping_instruction_id: shipping_instruction_id, invoice_id: invoice.id}
          elsif invoice.kind_of? DebitNote 
            params_uniq = {shipping_instruction_id: shipping_instruction_id, debit_note_id: invoice.id}
            params = {shipping_instruction_id: shipping_instruction_id, debit_note_id: invoice.id}
          elsif invoice.kind_of? Note
            params_uniq = {shipping_instruction_id: shipping_instruction_id, note_id: invoice.id}
            params = {shipping_instruction_id: shipping_instruction_id, note_id: invoice.id}
          end

          if invoice.has_due_date_invoice?
            name = "#{invoice.to_shipper} / #{invoice.invoice_no}"
            ibl_ref = si.ibl_ref
            etd_date = invoice.etd

            params[:name] = name
            params[:ibl_ref] = ibl_ref
            params[:etd_date] = etd_date

            monitoring = InvoiceMonitoring.find_by(params_uniq)  
            unless monitoring.blank?
              monitoring.update(params)
            else
              InvoiceMonitoring.create(params)
            end
          else
            InvoiceMonitoring.where(params_uniq).destroy_all
          end  
        end
      end
    end
  end
end
