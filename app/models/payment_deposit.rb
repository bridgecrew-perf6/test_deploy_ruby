class PaymentDeposit < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :_destroy

  with_options touch: true do |assoc| 
    assoc.belongs_to :payment, inverse_of: :payment_deposits
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
    assoc.belongs_to :shipping_instruction2, class_name: "ShippingInstruction", foreign_key: 'ibl_deposit', primary_key: 'si_no'
  end

  has_many :payment_references, through: :payment

  validates_presence_of :ibl_deposit, :ibl_ref, :amount

  delegate :carrier_name, :payment_no, :currency, :payment_type, :payment_date, :payment_no_with_status, :is_cancel, :carrier_id, :req_no, :status_info, :is_canceled?, :no, to: :payment, allow_nil: true
  delegate :ibl_ref_with_status, :first_etd_date, to: :shipping_instruction, allow_nil: true

  before_save :add_master_bl_no

  def add_master_bl_no
    self.master_bl_no = self.shipping_instruction2.master_bl_no
  end

  def master_bl_no_2
    self.shipping_instruction.master_bl_no
  end

  def self.with_filter(params)
    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      payments = PaymentReference.includes(:payment).where("payments.payment_no LIKE ? AND payment_references.amount_invoice IS NOT NULL", "%/#{year}").references(:payment)
    end

    # payments = payments.where("payment_references.amount_invoice < payment_references.amount")

    payments#.page(params[:page])
  end

  # after_commit :generate_workers

  # private
  # def generate_workers
  #   PaymentMonitoringWorker.perform_async(shipping_instruction.id)
  # end
end
