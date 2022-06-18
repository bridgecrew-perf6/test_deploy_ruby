class DailySiMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # First order of queues
  sidekiq_options queue: :daily_si_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(0) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(40) }

  def perform
    # ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED)
    #   .open.find_each do |shipping_instruction|
    #   SiMonitoringWorker.process_si_monitoring(shipping_instruction.id)
    # end

    # Revisi 27 October 2015    
    # SiMonitoring.destroy_all
    # Revisi 18 May 2015
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      SiMonitoringWorker.process_si_monitoring(shipping_instruction.id)
    end
  end
end
