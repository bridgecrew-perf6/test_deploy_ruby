class DailyPaymentMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options queue: :daily_payment_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(15) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(50) }

  def perform
  	# Revisi 27 October 2015    
    # PaymentMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      PaymentMonitoringWorker.process_payment_monitoring(shipping_instruction.id)
    end
  end
end
