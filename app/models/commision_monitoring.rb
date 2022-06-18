class CommisionMonitoring < ActiveRecord::Base
  ###############################
  #
  # DEPRECATED SINCE 19 May 2015
  #
  ###############################
  
  # belongs_to :shipping_instruction
  # belongs_to :cost_revenue
  #
  # default_scope -> { where(hidden: false) }
  #
  # def name
  #   [hbl_no, (mbl_no.presence || '-- MBL # --')].join(' / ')
  # end
end
