class DailySellCostMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Sixth order of queues
  sidekiq_options queue: :daily_sell_cost_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(30) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(52) }

  def perform
    # SellCostMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      SellCostMonitoringWorker.process_sell_cost_monitoring(shipping_instruction.id)
    end
  end
end
