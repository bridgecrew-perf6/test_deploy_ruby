class PaymentReference < ActiveRecord::Base
  include UpcaseAttributes
  include ActionView::Helpers::NumberHelper

  attr_accessor :_destroy

  with_options touch: true do |assoc|
    assoc.belongs_to :payment, inverse_of: :payment_references
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
  end

  has_many :payment_deposits, through: :payment

  # validates_presence_of :ibl_ref, :booking_no, :amount
  validates_presence_of :ibl_ref, :amount

  delegate :carrier_name, :payment_no, :currency, :payment_type, :payment_date, :payment_no_with_status, :is_cancel, :carrier_id, :req_no, :no, :status_info, :is_canceled?, :is_uncanceled?, to: :payment, allow_nil: true
  delegate :shipper_company_name, :final_destination, :volume, :first_etd_date, :ibl_ref_with_status, :si_date, :port_of_loading, :ibl_ref, :master_bl_no, to: :shipping_instruction, allow_nil: true

  # validate :compare_invoice_with_estimate

  after_commit :generate_workers

  before_save :add_master_bl_no

  def add_master_bl_no
    self.master_bl_no = self.shipping_instruction.master_bl_no
    self.booking_no = self.shipping_instruction.booking_no
  end

  def amount_tax
    total = 0
    self.payment.payment_taxes.where(ibl_ref: self.ibl_ref).each do |tax|
      total+=tax.amount.to_f
    end
    total
  end

  def self.payment_no(si_no)
    where(ibl_ref: si_no).map(&:payment_no)
  end

  def self.with_filter(params)
    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      payments = PaymentReference.includes(:payment).where("payments.payment_no LIKE ?", "%/#{year}").references(:payment)
    end

    # payments = payments.where("payment_references.amount_invoice < CONVERT(payment_references.amount,DECIMAL(10,2))")
    # payments = payments.where("payment_references.amount_invoice > 0")
    payments = payments.where("payment_references.amount_invoice < payment_references.amount")

    payments#.page(params[:page])
  end

  def amount_deposit
    amount_payment = self.amount
    amount_invoice = self.amount_invoice

    amount_payment = amount_payment.gsub(",", "").to_f if amount_payment.to_s.include? ','
    amount_payment.to_f - amount_invoice.to_f
  end

  def deposit_balance
    amount_payment = self.amount
    amount_invoice = self.amount_invoice

    amount_payment = amount_payment.gsub(",", "").to_f if amount_payment.to_s.include? ','
    amount_payment.to_f - amount_invoice.to_f
  end

  def ibl_deposit
    deposit_balance = number_with_delimiter(number_with_precision(self.deposit_balance, precision: 2).to_f)
    [self.ibl_ref.to_s, deposit_balance.to_s].join(' - ')
  end

  def amount_use_deposit
    # amount = 0
    # self.payment.payment_deposits.each do |deposit|
    #   amount += deposit.amount.to_f if (deposit.ibl_ref == self.ibl_ref) && (!deposit.marked_for_destruction?)
    # end
    # amount.round(2)
    # self.payment_deposits.map{|p| p.amount if p.ibl_ref == self.ibl_ref && !p.marked_for_destruction?}.sum(&:to_f).round(2)  
    self.payment_deposits.map{|p| p.amount if p.ibl_ref == self.ibl_ref}.sum(&:to_f).round(2)
  end

  def amount_estimate
    (self.amount.to_f + self.amount_use_deposit.to_f - self.amount_misc.to_f - self.amount_overpaid.to_f).round(2)
  end

  # def amount_estimate_without_use_deposit
  #   (self.amount.to_f - self.amount_misc.to_f - self.amount_overpaid.to_f).round(2)
  # end

  # def compare_invoice_with_estimate
  #   if self.marked_for_destruction?
  #     true
  #     # raise "destroy"
  #   else
  #     # (self.amount_invoice == self.amount_estimate) ? true : false
  #     unless self.amount_invoice == self.amount_estimate
  #       self.payment.errors.add(:base, "Reference #{self.ibl_ref} can't request #{self.amount_invoice} #{self.amount_estimate}")
  #       # self.payment.errors.add(:base, "Reference #{self.ibl_ref} can't request")
  #       return
  #     end
  #   end
  # end

  private
  def generate_workers
    PaymentMonitoringWorker.perform_async(shipping_instruction.id)
  end
end
