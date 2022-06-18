class BulkClosePayment < ActiveRecord::Base
  self.table_name = "invoices"
  self.primary_key = "id"

  include UpcaseAttributes

  attr_accessor :close_payment_rate, :close_payment_date, :close_payment_status, :close_payment_close_ref

  with_options dependent: :destroy do |assoc|
    assoc.has_many :additional_payments, class_name: "InvoicePayment", foreign_key: 'invoice_id'
    assoc.has_many :close_payments, class_name: "ClosePayment", foreign_key: 'invoice_id'
    assoc.has_many :deposit_payments, class_name: "InvoiceDeposit", foreign_key: 'invoice_id'
  end

	with_options allow_destroy: true do |nest_attr|
    nest_attr.accepts_nested_attributes_for :close_payments, :reject_if => lambda { |a| a[:invoice_no].blank? }
    nest_attr.accepts_nested_attributes_for :additional_payments, :reject_if => lambda { |a| a[:invoice_no].blank? }
    nest_attr.accepts_nested_attributes_for :deposit_payments, :reject_if => lambda { |a| a[:invoice_deposit].blank? || a[:invoice_no].blank? }
  end

  validate :check_close_payments
  before_validation :set_close_payment
  after_save :update_close_payment

  def generate_close_ref
    close_ref_no = (ClosePayment.pluck("distinct close_ref").delete_if{|e| e.blank?}.count+1).to_s
    base = []
    (3-close_ref_no.length).times{ base.push "0" }
    str = base.join() + close_ref_no
    str
  end

  def set_close_payment
    self.close_payments.each do |value|
      value.rate = self.close_payment_rate
      value.payment_date = self.close_payment_date
      value.status = self.close_payment_status
      value.close_ref = self.close_payment_close_ref.blank? ? self.generate_close_ref : self.close_payment_close_ref
    end
  end

  def update_close_payment
    begin
      close_ref_no = self.close_payments.last.try(:close_ref)

      self.close_payments.each do |payment|
        additional = self.additional_payments.where(invoice_no: payment.invoice_no)
        additional.update_all(invoice_id: nil, ibl_ref: payment.ibl_ref, close_payment_id: payment.id)

        deposit = self.deposit_payments.where(invoice_no: payment.invoice_no)
        deposit.update_all(invoice_id: nil, close_payment_id: payment.id)
      end

      batch_id = ClosePayment.pluck("distinct batch_id").delete_if{|e| e.blank?}.count+1
      self.close_payments.update_all(invoice_id: nil, batch_id: batch_id)
      ClosePayment.where(close_ref: close_ref_no).where.not(batch_id: batch_id).update_all(is_shadow: true) unless close_ref_no.blank?
    rescue
    end
  end

  def check_close_payments
    if self.close_payment_date.blank? || self.close_payment_status.blank?
     errors.add(:base, "Payment Date and Status can't be blank")
    end
    
    bulk_invoice_no = self.close_payments.map{|value| value.invoice_no unless value.marked_for_destruction?}
    if bulk_invoice_no.uniq.count == 0
      errors.add(:base, "Close Payment is empty")
    elsif bulk_invoice_no.count != bulk_invoice_no.uniq.count
      errors.add(:base, "Duplicate Invoice No in Close Payment isn't allowed")
    end

    bulk_customer = self.close_payments.map{|value| value.customer unless value.marked_for_destruction?}
    errors.add(:base, "Please Close Payment each Customer separately") if bulk_customer.uniq.count > 1

    self.close_payments.each do |value|
      unless value.marked_for_destruction?
        inv = InvoiceServices.find_with_invoice_no(value.invoice_no)
        si = inv.shipping_instruction
        # unless inv.invoice_inquiry.blank?
        #   if inv.is_payment_closed?
        #     errors.add(:base, "#{value.invoice_no} is closed")
        #   elsif inv.is_canceled?
        #     errors.add(:base, "#{value.invoice_no} is canceled")
        #   elsif inv.invoice_inquiry.close_ref != self.close_payment_close_ref
        #     errors.add(:base, "#{value.invoice_no} is already registered")
        #   end
        # end
        # if inv.is_payment_closed?
        #   errors.add(:base, "#{value.invoice_no} is closed")
        # end
        if inv.is_canceled?
          errors.add(:base, "#{value.invoice_no} is canceled")
        end

        unless inv.invoice_inquiry.blank?
          if inv.invoice_inquiry.close_ref != self.close_payment_close_ref
            errors.add(:base, "#{value.invoice_no} is already registered")
          end
        end
      end
    end

    self.additional_payments.each do |value|
      unless value.marked_for_destruction?
        errors.add(:base, "#{value.invoice_no} Not Listed. Please revise") unless bulk_invoice_no.include? value.invoice_no
      end
    end

    self.deposit_payments.each do |value|
      unless value.marked_for_destruction?
        errors.add(:base, "#{value.invoice_no} Not Listed. Please revise") unless bulk_invoice_no.include? value.invoice_no
      end
    end

    # self.close_payments.each do |value|
    #   unless value.marked_for_destruction?
    #     inv = InvoiceServices.find_with_invoice_no(value.invoice_no)
    #     unless inv.is_printed?
    #       errors.add(:base, "Cannot Close Payment. Invoice #{value.invoice_no} still not printed")
    #     end
    #   end
    # end
  end

  def close_payment_is_changed?
    new_record = {}
    new_record[:rate] = self.close_payment_rate.to_f
    new_record[:payment_date] = Date.parse(self.close_payment_date)
    new_record[:status] = self.close_payment_status.to_i
    new_record[:close_ref] = self.close_payment_close_ref

    self.close_payments.each do |value|
      unless value.marked_for_destruction?
        new_record[:close_payments] = {ibl_ref: value.ibl_ref, customer: value.customer, shipper: value.shipper, invoice_no: value.invoice_no, currency: value.currency, amount: value.amount.to_f}
      end
    end

    self.additional_payments.each do |value|
      unless value.marked_for_destruction?
        new_record[:additionals] = {invoice_no: value.invoice_no, bank_charge: value.bank_charge.to_f, rounding: value.rounding.to_f, short_paid: value.short_paid.to_f, deposit: value.deposit.to_f, pph_23: value.pph_23.to_f, other: value.other.to_f, note: value.note}
      end
    end

    self.deposit_payments.each do |value|
      unless value.marked_for_destruction?
        new_record[:use_deposits] = {invoice_deposit: value.invoice_deposit, ibl_deposit: value.ibl_deposit, amount: value.amount.to_f, invoice_no: value.invoice_no}
      end
    end

    old_record = {}
    close_payments = ClosePayment.where(close_ref: self.close_payment_close_ref, is_shadow: false)
    old_record[:rate] = close_payments.last.rate.to_f
    old_record[:payment_date] = close_payments.last.payment_date
    old_record[:status] = close_payments.last.status
    old_record[:close_ref] = close_payments.last.close_ref
    close_payments.each do |inv|
      old_record[:close_payments] = {ibl_ref: inv.ibl_ref, customer: inv.customer, shipper: inv.shipper, invoice_no: inv.invoice_no, currency: inv.currency, amount: inv.amount.to_f}
      inv.invoice_payments.each do |p|
        old_record[:additionals] = {invoice_no: p.invoice_no, bank_charge: p.bank_charge.to_f, rounding: p.rounding.to_f, short_paid: p.short_paid.to_f, deposit: p.deposit.to_f, pph_23: p.pph_23.to_f, other: p.other.to_f, note: p.note}
      end
      inv.invoice_deposits.each do |p|
        old_record[:deposits] = {invoice_deposit: p.invoice_deposit, ibl_deposit: p.ibl_deposit, amount: p.amount.to_f, invoice_no: p.invoice_no}
      end
    end

    new_record.to_s != old_record.to_s
  end

  def self.get_invoice_deposit(params)
    if params[:customer].blank?
      @get_invoice_deposit = {success: false, message: "Select a Customer first"}
    else
      additionals = InvoicePayment.includes(:close_payment).where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL").references(:close_payment)
      deposits = InvoiceDeposit.includes(:close_payment).where.not("invoice_deposits.amount IN ('0','') OR invoice_deposits.amount IS NULL").references(:close_payment)
    
      additionals = additionals.where("close_payments.is_shadow = ?", false)
      deposits = deposits.where("close_payments.is_shadow = ?", false)

      additionals = additionals.where("close_payments.customer IN (?)", params[:customer])
      deposits = deposits.where("close_payments.customer IN (?)", params[:customer])

      if additionals.blank?
        @get_invoice_deposit = {success: false, message: "No Deposit Additional"}
      else
        data = []
        additionals.order(invoice_no: :desc).group_by(&:invoice_no).each do |invoice_no, adds|
          deposit_balance = adds.map{|p| p.deposit}.sum(&:to_f) - deposits.where(invoice_deposit: invoice_no).map{|p| p.amount}.sum(&:to_f)

          close_deposit = InvoiceCloseDeposit.where(invoice_no: invoice_no).first
          deposit_balance -= close_deposit.try(:amount).to_f

          data.push(
            { ibl_ref: adds.first.ibl_ref,
              invoice_no: invoice_no,
              currency: adds.first.currency_2,
              deposit_balance: deposit_balance
            }
          ) if deposit_balance.to_f > 0
        end
        @get_invoice_deposit = begin
          if data.nil? || data.blank?
            {success: false, message: "No Deposit Balance"}
          else
            {success: true, results: data}
          end
        end
      end
    end
    @get_invoice_deposit
  end
end
