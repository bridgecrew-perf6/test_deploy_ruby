class CrMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cr_monitoring

  def perform(shipping_instruction_id)
    # if cost_revenue = CostRevenue.find(cost_revenue_id)
    #   shipping_instruction = cost_revenue.shipping_instruction
    #   vessel = shipping_instruction.vessels.first
    #   data = { cost_revenue: cost_revenue, hbl_no: shipping_instruction.si_no, mbl_no: shipping_instruction.master_bl_no }
    #
    #   if cost_revenue.completed?
    #     CrMonitoring.find_by(data).destroy
    #   else
    #     monitoring = CrMonitoring.find_or_create_by(data)
    #     monitoring.update(shipment_date: vessel.etd_date)
    #   end
    # end

    # Revisi 19 May 2015
    self.class.process_cr_monitoring(shipping_instruction_id)
  end

  private
  # def self.process_cr_monitoring(shipping_instruction_id)
  #   if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
  #     first_vessel = shipping_instruction.vessels.first
  #     cost_revenue = CostRevenue.find_by(shipping_instruction_id: shipping_instruction.id)

  #     if cr_monitoring = CrMonitoring.find_by(shipping_instruction_id: shipping_instruction.id)
  #       # if cost_revenue && cost_revenue.try(:completed?)
  #       # Revisi 13 November 2015
  #       if !cost_revenue.blank? && cost_revenue.try(:completed?)
  #         cr_monitoring.try(:destroy)
  #       else
  #         if first_vessel #&& shipping_instruction.si_no.presence && shipping_instruction.master_bl_no.presence
  #           cr_monitoring.update(cost_revenue_id: cost_revenue.try(:id), shipping_instruction_id: shipping_instruction.id,
  #                                 hbl_no: shipping_instruction.si_no, mbl_no: shipping_instruction.master_bl_no, shipment_date: first_vessel.etd_date)
  #         end
  #       end
  #     else
  #       if first_vessel #&& shipping_instruction.si_no.presence && shipping_instruction.master_bl_no.presence
  #         # return if cost_revenue.try(:completed?)
  #         # Revisi 4 November 2015
  #         # return if cost_revenue && cost_revenue.try(:completed?)
  #         # Revisi 13 November 2015
  #         return if !cost_revenue.blank? && cost_revenue.try(:completed?)

  #         CrMonitoring.create(cost_revenue_id: cost_revenue.try(:id), shipping_instruction_id: shipping_instruction.id,
  #                             hbl_no: shipping_instruction.si_no, mbl_no: shipping_instruction.master_bl_no, shipment_date: first_vessel.etd_date)
  #       end
  #     end
  #   end
  # end
  def self.process_cr_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   cost_revenue = CostRevenue.find_by(shipping_instruction_id: shipping_instruction.id)
    #   cr_monitoring = CrMonitoring.find_by(shipping_instruction_id: shipping_instruction.id)

    #   if !cost_revenue.blank? && cost_revenue.is_open?
    #     if cr_monitoring.blank?
    #       CrMonitoring.create(cost_revenue_id: cost_revenue.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                         hbl_no: shipping_instruction.si_no, mbl_no: shipping_instruction.master_bl_no, shipment_date: shipping_instruction.first_etd_date)
    #     else
    #       cr_monitoring.update(cost_revenue_id: cost_revenue.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                             hbl_no: shipping_instruction.si_no, mbl_no: shipping_instruction.master_bl_no, shipment_date: shipping_instruction.first_etd_date)
    #     end
    #     return
    #   end
    #   cr_monitoring.try(:destroy)
    # end


    si = ShippingInstruction.find(shipping_instruction_id)
    if si.has_outstanding_cr?
      name = "#{si.ibl_ref} / #{si.master_bl_no}"
      cr = si.cost_revenue
      name = "#{cr.ibl_ref} / #{cr.master_bl_no}" unless cr.blank?
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date
        
      monitoring = CrMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      else
        CrMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      CrMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
