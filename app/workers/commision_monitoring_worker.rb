class CommisionMonitoringWorker
  ###############################
  #
  # DEPRECATED SINCE 19 May 2015
  #
  ###############################

  # include Sidekiq::Worker
  # sidekiq_options queue: :commision_monitoring
  #
  # def perform(shipping_instruction_id)
  #   self.class.process_commision_monitoring(shipping_instruction_id)
  # end
  #
  # private
  # def self.process_commision_monitoring(shipping_instruction_id)
  #   shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
  #
  #   if cost_revenue = shipping_instruction.cost_revenue
  #     find_data = { shipping_instruction: shipping_instruction, cost_revenue: cost_revenue }
  #     attributes = find_data.merge(hbl_no: shipping_instruction.si_no, mbl_no: shipping_instruction.master_bl_no)
  #
  #     if cost_revenue.completed?
  #       if commision_monitoring = CommisionMonitoring.find_by(find_data)
  #         commision_monitoring.update(attributes)
  #       else
  #         CommisionMonitoring.create(attributes)
  #       end
  #     else
  #       if commision_monitoring = CommisionMonitoring.find_by(find_data)
  #         commision_monitoring.destroy
  #       end
  #     end
  #   end
  # end
end
