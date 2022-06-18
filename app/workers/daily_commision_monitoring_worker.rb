class DailyCommisionMonitoringWorker
  ###############################
  #
  # DEPRECATED SINCE 19 May 2015
  #
  ###############################
  
  # include Sidekiq::Worker
  # include Sidetiq::Schedulable
  #
  # # Third order of queues
  # sidekiq_options queue: :daily_commision_monitoring
  #
  # recurrence { daily.hour_of_day(0).minute_of_hour(15) }
  #
  # def perform
  #   CostRevenue.includes(:shipping_instruction).completed.where(shipping_instructions: { is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED, status: ShippingInstruction::CLOSED })
  #     .where.not(shipping_instruction_id: CommisionMonitoring.pluck(:shipping_instruction_id)).find_each do |cost_revenue|
  #     CommisionMonitoringWorker.process_commision_monitoring(cost_revenue.shipping_instruction_id)
  #   end
  # end
end
