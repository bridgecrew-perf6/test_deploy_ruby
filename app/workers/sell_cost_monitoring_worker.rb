class SellCostMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :sell_cost_monitoring

  def perform(shipping_instruction_id)
    self.class.process_sell_cost_monitoring(shipping_instruction_id)
  end

  private
  def self.process_sell_cost_monitoring(shipping_instruction_id)
    # if shipping_instruction = ShippingInstruction.find(shipping_instruction_id)
    #   cost_revenue = CostRevenue.find_by(shipping_instruction_id: shipping_instruction.id)
    #   sell_cost_monitoring = SellCostMonitoring.find_by(shipping_instruction_id: shipping_instruction.id)
        
    #   unless cost_revenue.blank?
    #     valid = false

    #     valid = true if shipping_instruction.shipper_company_name != cost_revenue.shipper_company_name
    #     valid = true if shipping_instruction.final_destination != cost_revenue.final_destination
    #     valid = true if shipping_instruction.volume != cost_revenue.volume
    #     valid = true if cost_revenue.selling_total_invoice == 0
    #     valid = true if cost_revenue.buying_total_invoice == 0

    #     if valid
    #       if sell_cost_monitoring.blank?
    #         SellCostMonitoring.create(cost_revenue_id: cost_revenue.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                           ibl_ref: shipping_instruction.si_no, shipper_company_name: cost_revenue.shipper_company_name, etd_date: cost_revenue.etd_date)
    #       else
    #         sell_cost_monitoring.update(cost_revenue_id: cost_revenue.try(:id), shipping_instruction_id: shipping_instruction.id,
    #                           ibl_ref: shipping_instruction.si_no, shipper_company_name: cost_revenue.shipper_company_name, etd_date: cost_revenue.etd_date)
    #       end
    #       return
    #     end
    #   end
    #   sell_cost_monitoring.try(:destroy)
    # end


    si = ShippingInstruction.find(shipping_instruction_id)
    if si.has_outstanding_cost_and_sell?
      name = "#{si.ibl_ref} / #{si.shipper_company_name}"
      cr = si.cost_revenue
      name = "#{cr.ibl_ref} / #{cr.shipper_company_name}" unless cr.blank?
      ibl_ref = si.ibl_ref
      etd_date = si.first_etd_date
        
      monitoring = SellCostMonitoring.find_by(shipping_instruction_id: shipping_instruction_id)
      unless monitoring.blank?
        monitoring.update(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      else
        SellCostMonitoring.create(shipping_instruction_id: shipping_instruction_id, name: name, ibl_ref: ibl_ref, etd_date: etd_date)
      end
      # return
    else
      SellCostMonitoring.where(shipping_instruction_id: shipping_instruction_id).destroy_all
    end
  end
end
