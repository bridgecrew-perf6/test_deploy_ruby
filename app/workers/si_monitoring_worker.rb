class SiMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :si_monitoring

  def perform(shipping_instruction_id)
    SiMonitoringWorker.process_si_monitoring(shipping_instruction_id)
  end

  private
  def self.process_si_monitoring(shipping_instruction_id)
    # destroy = false
    # shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    # si_monitoring = SiMonitoring.find_or_create_by(shipping_instruction: shipping_instruction, si_no: shipping_instruction.si_no)
    #
    # if shipping_instruction.is_canceled? || shipping_instruction.is_closed?
    #   destroy = true
    # elsif shipping_instruction.is_open?
    #   destroy = true if shipping_instruction.bill_of_lading
    #
    #   if first_vessel = shipping_instruction.vessels.first
    #     si_monitoring.update(shipment_date: first_vessel.etd_date)
    #     time_confirmation = first_vessel.etd_date
    #     destroy = true if time_confirmation > Time.now
    #   end
    # end
    #
    # si_monitoring.destroy if destroy

    # Revisi 18 May 2015
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   if shipping_instruction.is_open? && !(shipping_instruction.is_canceled? || shipping_instruction.is_closed?)
    #     if shipping_instruction.bill_of_lading
    #       SiMonitoring.where(shipping_instruction_id: shipping_instruction.id).destroy_all
    #     else
    #       first_vessel = shipping_instruction.vessels.first
    #       created_by = User.find(shipping_instruction.create_by)
    #       si_no = "#{shipping_instruction.si_no} / #{created_by.username}"

    #       if si_monitoring = SiMonitoring.find_by(shipping_instruction_id: shipping_instruction.id)
    #         # Revisi 26 October 2015
    #         # if si_no && (first_vessel && first_vessel.etd_date <= DateTime.now.in_time_zone("Jakarta").to_date) # ori line
    #         # if si_no && (!first_vessel.blank? && first_vessel.etd_date <= DateTime.now.in_time_zone("Jakarta").to_date) # check first_vessel.blank?
    #         if si_no && (!first_vessel.blank? && (!first_vessel.etd_date.blank? && first_vessel.etd_date <= DateTime.now.in_time_zone("Jakarta").to_date)) # check first_vessel.etd_date.blank?
    #           si_monitoring.update(shipping_instruction_id: shipping_instruction.id, si_no: si_no, shipment_date: first_vessel.etd_date)
    #           return
    #         end
    #       else
    #         # Revisi 26 October 2015
    #         # if si_no && (first_vessel && first_vessel.etd_date <= DateTime.now.in_time_zone("Jakarta").to_date) # ori line
    #         # if si_no && (!first_vessel.blank? && first_vessel.etd_date <= DateTime.now.in_time_zone("Jakarta").to_date) # check first_vessel.blank?
    #         if si_no && (!first_vessel.blank? && (!first_vessel.etd_date.blank? && first_vessel.etd_date <= DateTime.now.in_time_zone("Jakarta").to_date)) # check first_vessel.etd_date.blank?
            
    #           SiMonitoring.create(shipping_instruction_id: shipping_instruction.id, si_no: si_no, shipment_date: first_vessel.etd_date)
    #           return
    #         end
    #       end
    #     end
    #   end

    #   SiMonitoring.where(shipping_instruction_id: shipping_instruction.id).destroy_all
    # end


    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   if si.bill_of_lading.blank?
    #     if si.is_open? && si.is_uncanceled?
    #       etd_date = si.first_etd_date
    #       author = si.author_name
    #       str = "#{si.ibl_ref} / #{author}"

    #       unless etd_date.blank?
    #         if etd_date <= DateTime.now.in_time_zone("Jakarta").to_date
    #           monitoring = SiMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
    #           unless monitoring.blank?
    #             monitoring.update(shipping_instruction_id: shipping_instruction_id, si_no: str, shipment_date: etd_date)
    #           else
    #             SiMonitoring.create(shipping_instruction_id: shipping_instruction_id, si_no: str, shipment_date: etd_date)
    #           end
    #           return
    #         end
    #       end
    #     end
    #   end  
    # end
    # SiMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all


    si = ShippingInstruction.find(shipping_instruction_id)
    if si.has_outstanding_si?
      name = "#{si.ibl_ref} / #{si.handler_name}"
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date

      monitoring = SiMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        # monitoring.update(shipping_instruction_id: shipping_instruction_id, si_no: str, shipment_date: etd_date)
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      else
        # SiMonitoring.create(shipping_instruction_id: shipping_instruction_id, si_no: str, shipment_date: etd_date)
        SiMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      SiMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
