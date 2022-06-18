class PaymentMonitoringWorker
  include Sidekiq::Worker
  include ApplicationHelper

  sidekiq_options queue: :payment_monitoring

  def perform(shipping_instruction_id)
    self.class.process_payment_monitoring(shipping_instruction_id)
  end

  private
  def self.process_payment_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   if shipping_instruction.bill_of_lading && shipping_instruction.is_open? && !(shipping_instruction.is_canceled? || shipping_instruction.is_closed?)
    #     first_vessel = shipping_instruction.vessels.first

    #     if first_vessel && ((first_vessel.etd_date - 2.day) <= DateTime.now.in_time_zone("Jakarta").to_date)
    #       unless PaymentReference.find_by(ibl_ref: shipping_instruction.si_no)
    #         if shipping_instruction.si_no.presence && shipping_instruction.carrier.presence
    #           if payment_monitoring = PaymentMonitoring.find_by(shipping_instruction_id: shipping_instruction.id)
    #             payment_monitoring.update(shipping_instruction_id: shipping_instruction.id, hbl_no: shipping_instruction.si_no,
    #                                       carrier: shipping_instruction.carrier, shipment_date: first_vessel.etd_date)
    #           else
    #             PaymentMonitoring.create(shipping_instruction_id: shipping_instruction.id, hbl_no: shipping_instruction.si_no,
    #                                       carrier: shipping_instruction.carrier, shipment_date: first_vessel.etd_date)
    #           end

    #           return
    #         end
    #       end
    #     end
    #   end

    #   PaymentMonitoring.where(shipping_instruction_id: shipping_instruction.id).destroy_all
    # end

    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   if si.bill_of_lading && si.is_open? && !(si.is_canceled? || si.is_closed?)
    #     first_vessel = si.vessels.first

    #     if first_vessel && ((first_vessel.etd_date - 2.day) <= DateTime.now.in_time_zone("Jakarta").to_date)
    #       unless PaymentReference.find_by(ibl_ref: si.si_no)
    #         if si.si_no.presence && si.carrier.presence
    #           if payment_monitoring = PaymentMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
    #             payment_monitoring.update(shipping_instruction_id: shipping_instruction_id, hbl_no: si.si_no,
    #                                       carrier: si.carrier, shipment_date: first_vessel.etd_date)
    #           else
    #             PaymentMonitoring.create(shipping_instruction_id: shipping_instruction_id, hbl_no: si.si_no,
    #                                       carrier: si.carrier, shipment_date: first_vessel.etd_date)
    #           end

    #           return
    #         end
    #       end
    #     end
    #   end

    #   PaymentMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    # end

    # si = ShippingInstruction.find(shipping_instruction_id)
    # unless si.blank?
    #   if si.bill_of_lading && si.is_open? && !(si.is_canceled? || si.is_closed?)
    #     first_vessel = si.vessels.first

    #     if first_vessel && ((first_vessel.etd_date - 2.day) <= DateTime.now.in_time_zone("Jakarta").to_date)
    #       unless PaymentReference.find_by(ibl_ref: si.si_no)
    #         if si.si_no.presence && si.carrier.presence
    #           if payment_monitoring = PaymentMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
    #             payment_monitoring.update(shipping_instruction_id: shipping_instruction_id, hbl_no: si.si_no,
    #                                       carrier: si.carrier, shipment_date: first_vessel.etd_date)
    #           else
    #             PaymentMonitoring.create(shipping_instruction_id: shipping_instruction_id, hbl_no: si.si_no,
    #                                       carrier: si.carrier, shipment_date: first_vessel.etd_date)
    #           end

    #           return
    #         end
    #       end
    #     end
    #   end

    #   PaymentMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    # end

    si = ShippingInstruction.find(shipping_instruction_id)
    if si.has_outstanding_payment?
      name = "#{si.ibl_ref} / #{si.carrier}"
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date
        
      monitoring = PaymentMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      else
        PaymentMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      PaymentMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
