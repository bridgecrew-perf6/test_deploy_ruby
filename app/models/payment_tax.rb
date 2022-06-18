class PaymentTax < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
    assoc.belongs_to :payment
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  end

  validates_presence_of :ibl_ref, :amount

  # delegate :carrier, :payment_no, :currency, :payment_date, to: :payment, prefix: :payment, allow_nil: true
  delegate :carrier_name, :payment_no, :currency, :payment_date, to: :payment, allow_nil: true
  delegate :ibl_ref_with_status, :first_etd_date, to: :shipping_instruction, allow_nil: true

  def self.with_filter(params)
    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      payments = PaymentTax.includes(shipping_instruction: [ :vessels ], payment: [ carrier_bank: [:carrier] ]).where("payments.payment_no LIKE ?", "%/#{year}").references(:payment)
    end

    unless params[:tax_issued].to_s.blank?
      tax_issued = Date.parse(params[:tax_issued])
      payments = payments.where("payment_taxes.tax_issued >= ? and payment_taxes.tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
    end
    
    payments#.page(params[:page])
  end
  
  def paid_status
    self.is_paid ? "Yes" : "No" 
  end

  def amount_tax
    self.amount.to_f + " " + self.payment_currency
  end

  # after_commit :generate_workers

  # private
  # def generate_workers
  #   PaymentMonitoringWorker.perform_async(shipping_instruction.id)
  # end
end
