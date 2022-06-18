class DailyShipmentMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # First order of queues
  sidekiq_options queue: :daily_shipment_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(20) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(54) }

  def perform
    # Revisi 27 October 2015    
    # ShipmentMonitoring.destroy_all
    
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      ShipmentMonitoringWorker.process_shipment_monitoring(shipping_instruction.id)
    end
  end
end
