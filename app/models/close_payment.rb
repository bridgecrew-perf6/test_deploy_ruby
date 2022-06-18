class ClosePayment < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :_destroy

  with_options touch: true do |assoc|
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_ref', primary_key: 'si_no'
    assoc.belongs_to :invoice, foreign_key: 'invoice_no', primary_key: 'no_invoice'
    assoc.belongs_to :debit_note, foreign_key: 'invoice_no', primary_key: 'no_dbn'
    assoc.belongs_to :note, foreign_key: 'invoice_no', primary_key: 'no_note'
  end

  with_options dependent: :destroy do |assoc|
    # assoc.has_many :invoice_payments, class_name: "InvoicePayment", foreign_key: 'invoice_no', primary_key: 'invoice_no'
    assoc.has_many :invoice_payments
    assoc.has_many :invoice_references, class_name: "InvoicePayment"
    assoc.has_many :invoice_deposits
  end

  # delegate :ibl_ref_with_status, to: :shipping_instruction, allow_nil: true

  def self.initialize_new(params)
    invoices = []
    params[:invoice_no].each do |invoice_no|
      invoices.push Invoice.find_by(no_invoice: invoice_no) if invoice_no.include? "INV"
      invoices.push DebitNote.find_by(no_dbn: invoice_no) if invoice_no.include? "DBN"
      invoices.push Note.find_by(no_note: invoice_no) if invoice_no.include? "CRN" 
    end
    invoices
  end

  def status_text
    # if self.is_canceled?
    #   "Cancel"
    # else
      if self.status == 1
        "Closed"
      elsif self.status == 0
        "Open"
      # elsif self.status == 3
      #   "Printed"
      end
    # end 
  end

  def amount_2
    total = 0
    if self.currency_2 == "IDR" && self.currency == "USD"
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      total += (self.amount.to_f * rate).round(2)
    else
      total += self.amount.to_f
    end
    total.round(2)
  end

  def amount_paid
    total = 0
    # if self.currency_2 == "IDR" && self.currency == "USD"
    #   rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
    #   total += (self.amount.to_f * rate).round(2)
    # else
    #   total += self.amount.to_f
    # end
    total += self.amount_2.to_f
    # self.invoice_payments.each do |p|
    #   # total += 0 - p.bank_charge.to_f - p.discount.to_f - p.short_paid.to_f + p.deposit.to_f + p.pph_23.to_f - p.other.to_f
    #   total += 0 - p.bank_charge.to_f - p.rounding.to_f - p.short_paid.to_f + p.deposit.to_f + p.pph_23.to_f - p.other.to_f
    # end
    self.invoice_payments.each do |p|
      total += p.bank_charge.to_f + p.rounding.to_f + p.short_paid.to_f + p.deposit.to_f + p.pph_23.to_f + p.other.to_f
    end
    self.invoice_deposits.each do |p|
      total -= p.amount.to_f
    end
    total.round(2)
  end

  def is_invoice_payment_open?
    # inv = begin
    #   if invoice_no.include? "INV"
    #     Invoice.find_by(no_invoice: invoice_no)
    #   elsif invoice_no.include? "DBN"
    #     DebitNote.find_by(no_dbn: invoice_no)
    #   elsif invoice_no.include? "CRN"
    #     Note.find_by(no_note: invoice_no)
    #   end
    # end
    inv = InvoiceServices.find_with_invoice_no(invoice_no)
    inv.blank? ? false : inv.is_payment_open?
  end

  def close_ref_no
    batch = self.batch_id.to_s
    base = []
    (3-batch.length).times{ base.push "0" }
    str = base.join() + batch
    str
  end

  def currency_2
    str = self.currency
    str = "IDR" unless self.rate == 0
    str
  end

  def self.deposit_balance(invoice_no)
    # return if carrier_id.blank?
    # payment_references = PaymentReference.includes(:payment).where.not(amount_invoice: nil, amount_overpaid: nil).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_references.ibl_ref = ?", "IDR", carrier_id, ibl_ref).references(:payment)
    # payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_deposits.ibl_deposit = ?", "IDR", carrier_id, ibl_ref).references(:payment)
    
    # payment_references = payment_references.where("payments.is_cancel = ?", 0)
    # payment_deposits = payment_deposits.where("payments.is_cancel = ?", 0)

    # overpaid = payment_references.map{|p| p.amount_overpaid}.sum(&:to_f)
    # deposit = payment_deposits.map{|p| p.amount}.sum(&:to_f)

    # # (overpaid - deposit).round(2)
    # si = ShippingInstruction.where(si_no: ibl_ref).first
    # close_deposit = PaymentCloseDeposit.where(carrier_id: carrier_id, ibl_ref: ibl_ref, payment_type: "IDR")
    # close_deposit = close_deposit.blank? ? 0 : close_deposit.first.amount.to_f
    # (overpaid - deposit - close_deposit).round(2)

    # additionals = ClosePayment.where(invoice_no: invoice_no, is_shadow: false).last.invoice_payments.map{|p| p.deposit}.sum(&:to_f)
    # additionals.round(2)

    additionals = InvoicePayment.includes(:close_payment).where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL").references(:close_payment)
    deposits = InvoiceDeposit.includes(:close_payment).where.not("invoice_deposits.amount IN ('0','') OR invoice_deposits.amount IS NULL").references(:close_payment)
  
    additionals = additionals.where("close_payments.is_shadow = ?", false)
    deposits = deposits.where("close_payments.is_shadow = ?", false)

    additionals = additionals.where("invoice_payments.invoice_no = ?", invoice_no)
    deposits = deposits.where("invoice_deposits.invoice_deposit = ?", invoice_no)

    close_deposit = InvoiceCloseDeposit.where(invoice_no: invoice_no).first

    (additionals.map{|p| p.deposit}.sum(&:to_f) - deposits.map{|p| p.amount}.sum(&:to_f) - close_deposit.try(:amount).to_f).round(2)
  end

  def ibl_deposit_invoice_no
    "#{self.ibl_ref} - #{self.invoice_no}#{(' - ' + self.currency_2) if self.currency_2 == 'USD'}"
  end

  def self.generate_close_ref
    close_ref_no = (ClosePayment.pluck("distinct close_ref").delete_if{|e| e.blank?}.count+1).to_s
    base = []
    (3-close_ref_no.length).times{ base.push "0" }
    str = base.join() + close_ref_no
    str
  end
end
