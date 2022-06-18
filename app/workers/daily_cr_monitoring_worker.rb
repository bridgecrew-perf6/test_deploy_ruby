class DailyCrMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Third order of queues
  sidekiq_options queue: :daily_cr_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(10) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(44) }

  def perform
    # bl_monitorings = BlMonitoring.includes(:shipping_instruction).where(shipping_instructions:
    #   { is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED, status: ShippingInstruction::OPENED })
    # bl_monitorings.find_each do |bl_monitoring|
    #   shipping_instruction = bl_monitoring.shipping_instruction
    #   vessel = shipping_instruction.vessels.first
    #
    #   if cr_monitoring = CrMonitoring.find_by(hbl_no: bl_monitoring.hbl_no)
    #     cr_monitoring.update(cost_revenue: bl_monitoring.shipping_instruction.cost_revenue, hbl_no: bl_monitoring.hbl_no,
    #       mbl_no: bl_monitoring.mbl_no, shipment_date: vessel.etd_date)
    #   else
    #     CrMonitoring.find_or_create_by(cost_revenue: bl_monitoring.shipping_instruction.cost_revenue,
    #                                   hbl_no: bl_monitoring.hbl_no, mbl_no: bl_monitoring.mbl_no, shipment_date: vessel.etd_date)
    #   end
    # end
    #
    # CrMonitoring.where.not(hbl_no: bl_monitorings.pluck(:hbl_no)).delete_all

    # Revisi 27 October 2015    
    # CrMonitoring.destroy_all
    # Revisi 19 May 2015
    # ids = CostRevenue.pluck("distinct shipping_instruction_id")
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
    # ShippingInstruction.where(id: ids, is_shadow: false).find_each do |shipping_instruction|
      CrMonitoringWorker.process_cr_monitoring(shipping_instruction.id)
    end
    # CrMonitoring.where.not(shipping_instruction_id: ids).destroy_all
  end
end
