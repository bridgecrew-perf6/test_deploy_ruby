class CrMonitoring < ActiveRecord::Base # Outstanding C & R
  # belongs_to :shipping_instruction, foreign_key: 'hbl_no', primary_key: 'si_no'
  belongs_to :shipping_instruction
  has_one :cost_revenue, through: :shipping_instruction
  
  default_scope -> { where(hidden: false) }
  
  # def actual_name
  #   # [hbl_no, (mbl_no.presence || '-- MBL # --')].join(' / ')
  #   self.name
  # end

  def cost_revenue_id
    self.cost_revenue.try(:id)
  end
end
