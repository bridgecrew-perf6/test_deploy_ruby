class DailyBlMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Second order of queues
  sidekiq_options queue: :daily_bl_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(5) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(42) }

  def perform
    # BillOfLading.includes(:shipping_instruction).where(is_shadow: false, is_cancel: BillOfLading::UNCANCELED, shipping_instructions: { is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED, status: ShippingInstruction::OPENED })
    #   .find_each do |bill_of_lading|
    #   BlMonitoringWorker.process_bl_monitoring(bill_of_lading.id)
    # end
    #
    # BillOfLading.includes(:shipping_instruction).where(is_shadow: false, is_cancel: BillOfLading::UNCANCELED, shipping_instructions: { is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED, status: ShippingInstruction::CLOSED })
    #   .find_each do |bill_of_lading|
    #   hbl_no = bill_of_lading.bl_number.presence || bill_of_lading.shipping_instruction.si_no
    #   mbl_no = bill_of_lading.master_bl_no.presence || bill_of_lading.shipping_instruction.master_bl_no
    #   BlMonitoring.find_or_create_by(bill_of_lading: bill_of_lading, hbl_no: hbl_no, mbl_no: mbl_no, invoiced: true, closed: true)
    # end

    # Revisi 27 October 2015    
    # BlMonitoring.destroy_all
    # Revisi 18 May 2015
    # BillOfLading.includes(:shipping_instruction).where(is_shadow: false, is_cancel: BillOfLading::UNCANCELED, shipping_instructions: { is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED, status: ShippingInstruction::OPENED }).find_each do |bill_of_lading|
    #   BlMonitoringWorker.process_bl_monitoring(bill_of_lading.id)
    # end
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      BlMonitoringWorker.process_bl_monitoring(shipping_instruction.id)
    end
  end
end
