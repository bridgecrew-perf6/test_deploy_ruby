class ShipmentMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :shipment_monitoring

  def perform(shipping_instruction_id)
    self.class.process_shipment_monitoring(shipping_instruction_id)
  end

  private
  def self.process_shipment_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   # if shipping_instruction.is_open? && !(shipping_instruction.is_canceled? || shipping_instruction.is_closed?)
    #   shipment_tracking = shipping_instruction.shipment_tracking
    #   first_vessel = shipping_instruction.vessels.first

    #   if shipment_tracking && first_vessel
    #     actual_fu_date = shipment_tracking.fu_date.presence || first_vessel.etd_date.presence

    #     if actual_fu_date && actual_fu_date == DateTime.now.in_time_zone("Jakarta").to_date
    #       shipment_monitoring = ShipmentMonitoring.find_or_create_by(shipping_instruction_id: shipping_instruction.id)
    #       shipment_monitoring.update(shipment_tracking_id: shipment_tracking.id, hbl_no: shipping_instruction.si_no,
    #                                   mbl_no: shipping_instruction.master_bl_no, shipment_date: first_vessel.etd_date)

    #       return
    #     end
    #   end
    #   # end

    #   ShipmentMonitoring.where(shipping_instruction_id: shipping_instruction.id).destroy_all
    # end


    si = ShippingInstruction.find(shipping_instruction_id)
    if si.has_outstanding_tracking?
      # name = "#{si.ibl_ref} / #{si.master_bl_no}"
      name = "#{si.ibl_ref} / #{si.carrier}"
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date
        
      monitoring = ShipmentMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      else
        ShipmentMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      ShipmentMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
