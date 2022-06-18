class DailyInvoiceMonitoringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Sixth order of queues
  sidekiq_options queue: :daily_invoice_monitoring

  recurrence { daily.hour_of_day(18).minute_of_hour(35) }
  # recurrence { daily.hour_of_day(10).minute_of_hour(48) }

  def perform
    # InvoiceMonitoring.destroy_all
    ShippingInstruction.where(is_shadow: false, is_cancel: ShippingInstruction::UNCANCELED).find_each do |shipping_instruction|
      InvoiceMonitoringWorker.process_invoice_monitoring(shipping_instruction.id)
    end
  end
end
