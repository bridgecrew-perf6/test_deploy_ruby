class PaymentInvoice < ActiveRecord::Base
  attr_accessor :_destroy

  with_options touch: true do |assoc|
    # assoc.belongs_to :payment
    assoc.belongs_to :shipping_instruction
  end

  with_options dependent: :destroy do |assoc|
    assoc.has_many :payment_items, inverse_of: :payment_invoice

    assoc.has_many :fixed_items, -> { where(item_type: 0) }, class_name: "PaymentItem"
    assoc.has_many :active_items, -> { where(item_type: 1) }, class_name: "PaymentItem"
    assoc.has_many :volume_items, -> { where(item_type: 2) }, class_name: "PaymentItem"
    assoc.has_many :shipper_items, -> { where(item_type: 3) }, class_name: "PaymentItem"
    assoc.has_many :carrier_items, -> { where(item_type: 4) }, class_name: "PaymentItem"
  end

  delegate :si_no, :booking_no, :shipper_company_name, :port_of_loading, :final_destination, :first_etd_date, :bl_status, :master_bl_no, :volume, to: :shipping_instruction, allow_nil: true

  with_options allow_destroy: true do |nest_attr|
    nest_attr.accepts_nested_attributes_for :payment_items, :reject_if => lambda { |a| a[:description].blank? }

    nest_attr.accepts_nested_attributes_for :fixed_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :active_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :volume_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :shipper_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :carrier_items, :reject_if => lambda { |a| a[:description].blank? }
  end

  before_save :set_carrier_id

  def set_carrier_id
    self.carrier_id = Carrier.find_by(name: self.carrier).try(:id) if self.carrier_changed?
  end

  def self.with_filter(params)
    payment_invoices = PaymentInvoice.includes(shipping_instruction: [ :bill_of_lading, :shipper, :vessels ]).order(payment_date: :asc, carrier: :asc)
    payment_invoices = payment_invoices.where(is_paid: 0)

    shipping_instructions = ShippingInstruction.recent

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      shipping_instructions = shipping_instructions.where("si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
    end

    payment_invoices = payment_invoices.where(shipping_instruction: shipping_instructions)

    payment_invoices
  end

  # def vat_10
  #   total = 0
  #   self.payment_items.each do |item|
  #     total += item.total.to_f if item.add_vat_10
  #   end

  #   (total * 0.1).round(2)
  # end

  # def vat_1
  #   total = 0
  #   self.payment_items.each do |item|
  #     total += item.total.to_f if item.add_vat_1
  #   end

  #   (total * 0.01).round(2)
  # end

  # def pph_23
  #   total = 0
  #   self.payment_items.each do |item|
  #     total += item.total_after_tax.to_f if item.add_pph_23
  #   end

  #   (total * (-0.02)).round(2)
  # end
  
  def default_vat_10
    self.payment_items.map{|p| p.vat_10 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def default_vat_1
    self.payment_items.map{|p| p.vat_1 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def default_pph_23
    self.payment_items.map{|p| p.pph_23 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def total_invoice
    # total = 0
    # self.payment_items.each do |item|
    #   total += item.total_after_tax.to_f
    # end
    total = self.payment_items.map{|p| p.total unless p.marked_for_destruction?}.sum(&:to_f)
    total += self.other.to_f
    total += self.vat_10.to_f
    total += self.vat_1.to_f

    total.round(2)
  end

  def total_invoice_include_pph_23
    (self.total_invoice.to_f + self.pph_23.to_f).round(2)
  end

  def default_total_invoice
    total = self.payment_items.map{|p| p.total unless p.marked_for_destruction?}.sum(&:to_f)
    total += self.other.to_f
    total += self.default_vat_10.to_f
    total += self.default_vat_1.to_f

    total.round(2)
  end

  def default_total_invoice_include_pph_23
    (self.default_total_invoice.to_f + self.default_pph_23.to_f).round(2)
  end

  def currency
    currency = "IDR"
    currency = "USD" if (self.rate.to_f == 0 && self.payment_items.map(&:amount_idr).sum(&:to_f) == 0)

    currency
  end

  def vat_10_status_text
    self.vat_10_status ? 'Close' : 'Open'
  end

  def vat_1_status_text
    self.vat_1_status ? 'Close' : 'Open'
  end

  def pph_23_status_text
    self.pph_23_status ? 'Close' : 'Open'
  end

  def paid_status
    self.is_paid ? 'Yes' : 'No'
  end
end
