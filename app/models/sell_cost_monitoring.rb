class SellCostMonitoring < ActiveRecord::Base # Outstanding Cost & Sell
  # belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  belongs_to :shipping_instruction
  has_one :cost_revenue, through: :shipping_instruction

  # def actual_name
  #   # "#{ibl_ref} / #{shipper_company_name}"
  #   self.name
  # end

  def cost_revenue_id
    self.cost_revenue.try(:id)
  end
end
