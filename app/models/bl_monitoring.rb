class BlMonitoring < ActiveRecord::Base # Outstanding Invoicing
  # belongs_to :shipping_instruction, foreign_key: 'hbl_no', primary_key: 'si_no'
  belongs_to :shipping_instruction
  has_one :bill_of_lading, through: :shipping_instruction

  # scope :not_invoiced, -> { where(invoiced: false) }
  # scope :not_closed, -> { where(closed: false) }
  # scope :completed, -> { where(invoiced: true, closed: true) }
  # default_scope -> { where(hidden: false) }

  # def actual_name
  #   # [hbl_no, (mbl_no.presence || '-- MBL # --')].join(' / ')
  #   self.name
  # end

  def bill_of_lading_id
    self.bill_of_lading.try(:id)
  end
end
