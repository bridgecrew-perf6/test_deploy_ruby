class DailyDocumentMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Sixth order of queues
  sidekiq_options queue: :daily_document_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(25) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(46) }

  def perform
    # DocumentMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      DocumentMonitoringWorker.process_document_monitoring(shipping_instruction.id)
    end
  end
end
