class Invoice < ActiveRecord::Base
  include UpcaseAttributes
  include ActionView::Helpers::NumberHelper

	# attr_accessor :tipe, :default_total_amount, :default_vat_10, :default_vat_1, :default_total_include_vat, :default_pph_23, :default_total_after_pph_23, :default_rate
  attr_accessor :tipe
  attr_accessor :close_payment_rate, :close_payment_date, :close_payment_status, :close_payment_close_ref

	enum status_tax: [ :open, :completed ]

	OTHER_DETAILS = ["VAT 10%", "VAT 1%", "TOTAL INCLUDING VAT", "PPH 23", "TOTAL AFTER PPH 23"]

	RATE = ["RATE"]
  UNCANCELED = 0.freeze

  CLOSED = 1.freeze
	
  with_options touch: true do |assoc|
  	assoc.belongs_to :bill_of_lading
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_no', primary_key: 'si_no'
  end
	# has_many :payment_histories
	# has_many :payments, :through => :payment_histories
  with_options dependent: :destroy do |assoc|
    # assoc.has_many :invoice_details, -> { where.not(description: Invoice::OTHER_DETAILS).where.not(description: Invoice::RATE) }
    # assoc.has_many :invoice_other_details, -> { where(description: Invoice::OTHER_DETAILS) }, class_name: "InvoiceDetail"
    # assoc.has_one :invoice_rate, -> { where(description: Invoice::RATE) }, class_name: "InvoiceDetail"
    assoc.has_many :invoice_details, inverse_of: :invoice

    assoc.has_many :fixed_items, -> { where(item_type: 1) }, class_name: "InvoiceDetail"
    assoc.has_many :active_items, -> { where.not(item_type: 0) }, class_name: "InvoiceDetail"

    assoc.has_many :additional_payments, class_name: "InvoicePayment"
    # assoc.has_many :invoice_payments, class_name: "InvoicePayment", foreign_key: 'invoice_no', primary_key: 'no_invoice'
    assoc.has_many :close_payments, class_name: "ClosePayment"
    assoc.has_many :close_payment_histories, class_name: "ClosePayment", foreign_key: 'invoice_no', primary_key: 'no_invoice'
    
    # assoc.has_many :invoice_references, -> { includes(:close_payment).where("close_payments.is_shadow = false").references(:close_payment) }, class_name: "InvoicePayment", foreign_key: 'invoice_no', primary_key: 'no_invoice'
    assoc.has_many :deposit_payments, class_name: "InvoiceDeposit"
    # assoc.has_many :invoice_deposits, -> { includes(:close_payment).where("close_payments.is_shadow = false").references(:close_payment) }, class_name: "InvoiceDeposit", foreign_key: 'invoice_no', primary_key: 'no_invoice'

    # assoc.has_many :invoice_inquiries, -> { where(is_shadow: false) }, class_name: "ClosePayment", foreign_key: 'invoice_no', primary_key: 'no_invoice'
    assoc.has_one :invoice_inquiry, -> { where(is_shadow: false) }, class_name: "ClosePayment", foreign_key: 'invoice_no', primary_key: 'no_invoice'
    assoc.has_many :invoice_references, class_name: "InvoicePayment", through: :invoice_inquiry
    assoc.has_many :invoice_deposits, class_name: "InvoiceDeposit", through: :invoice_inquiry

    # assoc.has_many :cc_shortpaids, -> { where.not("invoice_payments.short_paid IN ('0','') OR invoice_payments.short_paid IS NULL") }, class_name: "InvoicePayment", through: :invoice_inquiry
    # assoc.has_many :cc_deposits, -> { where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL") }, class_name: "InvoicePayment", through: :invoice_inquiry
  end

	# accepts_nested_attributes_for :invoice_details, :reject_if => lambda { |a| a[:description].blank? || a[:description].nil? || 
	# 	a[:amount].blank? || a[:amount].nil? || a[:volume].blank? || a[:volume].nil? }, :allow_destroy => true
	with_options allow_destroy: true do |nest_attr|
    nest_attr.accepts_nested_attributes_for :invoice_details, :reject_if => lambda { |a| a[:description].blank? }
  	# nest_attr.accepts_nested_attributes_for :invoice_other_details, :reject_if => lambda { |a| a[:description].blank? }
  	# nest_attr.accepts_nested_attributes_for :invoice_rate, :reject_if => lambda { |a| a[:description].blank? }

    nest_attr.accepts_nested_attributes_for :fixed_items, :reject_if => lambda { |a| a[:description].blank? }
    nest_attr.accepts_nested_attributes_for :active_items, :reject_if => lambda { |a| a[:description].blank? }
    # nest_attr.accepts_nested_attributes_for :invoice_payments, :reject_if => lambda { |a| a[:payment_date].blank? }

    # nest_attr.accepts_nested_attributes_for :close_payments, :reject_if => lambda { |a| a[:payment_date].blank? || a[:invoice_no].blank? }
    # nest_attr.accepts_nested_attributes_for :additional_payments, :reject_if => lambda { |a| a[:payment_date].blank? || a[:invoice_no].blank? }
    # nest_attr.accepts_nested_attributes_for :deposit_payments, :reject_if => lambda { |a| a[:invoice_deposit].blank? || a[:invoice_no].blank? }
    nest_attr.accepts_nested_attributes_for :close_payments, :reject_if => lambda { |a| a[:invoice_no].blank? }
    nest_attr.accepts_nested_attributes_for :additional_payments, :reject_if => lambda { |a| a[:invoice_no].blank? }
    nest_attr.accepts_nested_attributes_for :deposit_payments, :reject_if => lambda { |a| a[:invoice_deposit].blank? || a[:invoice_no].blank? }
  end

  delegate :ibl_ref, :ibl_ref_with_status, :first_etd_date, to: :shipping_instruction, allow_nil: true

  scope :uncanceled, -> { where(is_cancel: UNCANCELED) }
  scope :closed, -> { where(status_payment: CLOSED) }
  scope :recent, -> {
    # references(:invoice_details, bill_of_lading: {shipping_instruction: [:shipper, :vessels, si_containers: [:container]]})
    # .includes(:invoice_details, bill_of_lading: {shipping_instruction: [:shipper, :vessels, si_containers: [:container]]})
    order(no_invoice: :desc)
  }
  scope :recent_with_vessels, -> {
    # references({bill_of_lading: {shipping_instruction: [:vessels]}}, :invoice_details)
    # .includes({bill_of_lading: {shipping_instruction: [:vessels]}}, :invoice_details)
    joins(:shipping_instruction, "LEFT OUTER JOIN vessels VS ON (VS.id = (SELECT SVS.id FROM vessels SVS WHERE SVS.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
  }
  scope :reports, -> {
    references({shipping_instruction: [:vessels]}, :invoice_details)
    .includes({shipping_instruction: [:vessels]}, :invoice_details)
    .joins("LEFT OUTER JOIN vessels VS ON (VS.id = (SELECT SVS.id FROM vessels SVS WHERE SVS.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
  }

  search_syntax do
    search_by :text do |scope, phrases|
      columns = [:no_invoice, :currency_code, :customer_ori, :to_shipper, :destination,
                 "shipping_instructions.si_no", "shipping_instructions.order_details"]
      scope.where_like(columns => phrases)
    end
  end

	validates_presence_of :currency_code, :customer, :message => "must be selected"
	validates_uniqueness_of :no_invoice, :message => "must be unique"

  # validate :check_close_payments

	# Revisi 1 Dec 2015
	before_create :set_volume
  after_commit :generate_workers

  # before_validation :set_close_payment
  # # before_save :set_close_ref
  # after_save :update_close_payment

  def generate_close_ref
    close_ref_no = (ClosePayment.pluck("distinct close_ref").delete_if{|e| e.blank?}.count+1).to_s
    base = []
    (3-close_ref_no.length).times{ base.push "0" }
    str = base.join() + close_ref_no
    str
  end

  def set_close_payment
    self.close_payments.each do |value|
      # unless value.marked_for_destruction?
        # inv = InvoiceServices.find_with_invoice_no(value.invoice_no)
        # si = inv.shipping_instruction
        value.rate = self.close_payment_rate
        value.payment_date = self.close_payment_date
        value.status = self.close_payment_status
        value.close_ref = self.close_payment_close_ref.blank? ? self.generate_close_ref : self.close_payment_close_ref
        # value.close_ref = self.close_payment_close_ref.blank? ? self.generate_close_ref : self.close_payment_close_ref
      # end
    end

    self.additional_payments.each do |value|
      value.payment_date = self.close_payment_date
    end
  end

  def set_close_ref
    self.close_payments.each do |value|
      value.close_ref = self.close_payment_close_ref.blank? ? ClosePayment.generate_close_ref : self.close_payment_close_ref
    end
  end

  def update_close_payment
    # raise self.close_payment_close_ref.inspect
    # raise self.close_payments.last.inspect
    close_ref_no = self.close_payments.last.try(:close_ref)
    # raise close_ref_no

    self.close_payments.each do |payment|

      additional = self.additional_payments.where(invoice_no: payment.invoice_no)
      
      inv = begin
        if payment.invoice_no.include? "INV"
          Invoice.find_by(no_invoice: payment.invoice_no)
        elsif payment.invoice_no.include? "DBN"
          DebitNote.find_by(no_dbn: payment.invoice_no)
        elsif payment.invoice_no.include? "CRN"
          Note.find_by(no_note: payment.invoice_no)
        end
      end
      # inv.update_attributes(status_payment: payment.status, notes_payment: additional.last.try(:note), date_of_payment: payment.payment_date) unless inv.blank?

      additional.update_all(invoice_id: nil, ibl_ref: payment.ibl_ref, close_payment_id: payment.id)


      deposit = self.deposit_payments.where(invoice_no: payment.invoice_no)
      # deposit.update_all(invoice_id: nil, ibl_ref: payment.ibl_ref, close_payment_id: payment.id)
      deposit.update_all(invoice_id: nil, close_payment_id: payment.id)

    end
    batch_id = ClosePayment.pluck("distinct batch_id").delete_if{|e| e.blank?}.count+1
    self.close_payments.update_all(invoice_id: nil, batch_id: batch_id)
    ClosePayment.where(close_ref: close_ref_no).where.not(batch_id: batch_id).update_all(is_shadow: true) unless close_ref_no.blank?
  end

  def check_close_payments
    # if self.close_payment_date.blank? || self.close_payment_status.blank?
    #  errors.add(:base, "Payment Date and Status can't be blank")
    # end
    
    result = self.close_payments.map{|value| value.invoice_no unless value.marked_for_destruction?}
    if result.uniq.count == 0
      errors.add(:base, "Close Payment is empty")
    elsif result.count != result.uniq.count
      errors.add(:base, "Duplicate Invoice No in Close Payment isn't allowed")
    end

    have_payment_date_and_status = true
    self.close_payments.each do |value|
      unless value.marked_for_destruction?
        if have_payment_date_and_status && (value.payment_date.blank? || value.status.blank?)
          errors.add(:base, "Payment Date and Status can't be blank")
          have_payment_date_and_status = false
        end
        # errors.add(:base, "Payment for Invoice No #{value.invoice_no} is closed") unless value.is_invoice_payment_open?

        inv = InvoiceServices.find_with_invoice_no(value.invoice_no)
        si = inv.shipping_instruction
        # # errors.add(:base, "Invoice No #{value.invoice_no} is closed") unless inv.is_payment_open?
        # # errors.add(:base, "Invoice No #{value.invoice_no} is canceled") unless inv.is_uncanceled?
        # # errors.add(:base, "Invoice No #{value.invoice_no} is CR completed") if si.is_cr_completed?
        # # errors.add(:base, "Invoice No #{value.invoice_no} is already registered") unless inv.close_payment_histories.blank?
        # if inv.is_payment_closed?
        #   errors.add(:base, "Invoice No #{value.invoice_no} is closed")
        # elsif inv.is_canceled?
        #   errors.add(:base, "Invoice No #{value.invoice_no} is canceled")
        # # elsif si.is_cr_completed?
        # #   errors.add(:base, "Invoice No #{value.invoice_no} is CR completed")
        # end
        # # errors.add(:base, "Invoice No #{value.invoice_no} is already registered") unless inv.close_payment_histories.blank?
        # # close_refs = inv.close_payment_histories.map(&:close_ref).uniq
        # # if close_refs.count == 1
        # #   errors.add(:base, "Invoice No #{value.invoice_no} is already registered") unless close_refs[0] == self.close_payment_close_ref
        # # end
        # unless inv.invoice_inquiry.blank?
        #   errors.add(:base, "Invoice No #{value.invoice_no} is already registered") unless inv.invoice_inquiry.close_ref == self.close_payment_close_ref
        # end

        unless inv.invoice_inquiry.blank?
          if inv.is_payment_closed?
            errors.add(:base, "Invoice No #{value.invoice_no} is closed")
          elsif inv.is_canceled?
            errors.add(:base, "Invoice No #{value.invoice_no} is canceled")
          elsif inv.invoice_inquiry.close_ref != self.close_payment_close_ref
            errors.add(:base, "Invoice No #{value.invoice_no} is already registered")
          end
        end
      end
    end

    self.additional_payments.each do |value|
      unless value.marked_for_destruction?
        errors.add(:base, "Invoice No #{value.invoice_no} Not Listed. Please revise") unless result.include? value.invoice_no
      end
    end

    self.deposit_payments.each do |value|
      unless value.marked_for_destruction?
        errors.add(:base, "Invoice No #{value.invoice_no} Not Listed. Please revise") unless result.include? value.invoice_no
      end
    end
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

	def set_volume
    self.volume = self.bill_of_lading.shipping_instruction.volume
  end
	
	def status_info
    if self.is_canceled?
      "Cancel"
    else
      if self.status == 1
        "Closed"
      elsif self.status == 0
        "Open"
      elsif self.status == 3
        "Printed"
      end
    end	
	end
	
  def status_text
		if status == 1
			"Closed"
		elsif status == 0
			"Open"
		elsif status == 3
			"Printed"
		end	
	end
  
  # def status_payment_text
  #   if status == 1
  #     "Closed"
  #   elsif status == 0
  #     "Open"
  #   end 
  # end
  
  def payment_status
    if self.close_payment_histories.blank?
      self.status_payment
    else
      # self.invoice_payments.order(payment_date: :desc).first.payment_date
      # tmp = self.close_payment_histories.where(is_shadow: false).last.try(:status)
      tmp = self.invoice_inquiry.try(:status)
      tmp.blank? ? 0 : tmp
    end
  end

  def payment_status_text
    if self.is_canceled?
      "Cancel"
    else
      if self.payment_status == 1
        "Closed"
      elsif self.payment_status == 0
        "Open"
      end
    end
  end

	# def bl_no
	# 	split = self.bl_ibl_no.split("/")
	# 	return split[0]
	# end

	# def ibl_no
	# 	split = self.bl_ibl_no.split("/")
	# 	return split[1]
	# end

  def grand_total
    # return if self.is_canceled?
    # if self.add_total_after_pph_23
    #   self.total_after_pph_23
    # elsif self.add_total_include_vat
    #   self.total_include_vat
    # else
    #   self.total_amount
    # end
    self.total_after_pph_23
  end

  def total_invoice
    self.total_amount.to_f.round(2)
  end

  def total_amount
    # return if self.is_canceled?
    total = 0
    self.invoice_details.each do |d|
      total += d.subtotal.to_f
    end
    total.round(2)
  end

  # def vat_10
  #   # return if self.is_canceled?
  #   (self.total_amount.to_f * 0.1).round(2) if self.add_vat_10
  # end

  # def vat_1
  #   # return if self.is_canceled?
  #   (self.total_amount.to_f * 0.01).round(2) if self.add_vat_1
  # end

  def total_include_vat
    # return if self.is_canceled?
    # (self.total_amount.to_f + self.vat_10.to_f + self.vat_1.to_f).round(2) if self.add_total_include_vat
    (self.total_amount.to_f + self.vat_10.to_f + self.vat_1.to_f).round(2)
  end

  # def pph_23
  #   # return if self.is_canceled?
  #   (self.total_amount.to_f * 0.02 * -1).round(2) if self.add_pph_23
  # end

  def total_after_pph_23
    # return if self.is_canceled?
    # (self.total_amount.to_f + self.vat_10.to_f + self.vat_1.to_f + self.pph_23.to_f).round(2) if self.add_total_after_pph_23
    (self.total_amount.to_f + self.vat_10.to_f + self.vat_1.to_f + self.pph_23.to_f).round(2)
  end

  def freight
    # return if self.is_canceled?
    # (self.total_invoice.to_f - self.vat_10.to_f - self.vat_1.to_f - self.pph_23.to_f).round(2)
    # (self.total_amount.to_f).round(2)
    # (self.grand_total.to_f - self.vat_10_tax.to_f - self.vat_1_tax.to_f - self.pph_23_tax.to_f).round(2)
    (self.total_amount.to_f).round(2)
  end

  def payment_date
    if self.close_payment_histories.blank?
      self.date_of_payment
    else
      # self.invoice_payments.order(payment_date: :desc).first.payment_date
      # self.close_payment_histories.last.payment_date
      # tmp = self.close_payment_histories.where(is_shadow: false).last.try(:payment_date)
      tmp = self.invoice_inquiry.try(:payment_date)
      tmp.blank? ? nil : tmp
    end
  end

  def payment_note
    # if self.invoice_payments.blank?
    #   self.notes_payment
    # else
    #   # self.invoice_payments.order(payment_date: :desc).first.note
    #   # self.invoice_payments.last.note
    #   tmp = self.close_payment_histories.where(is_shadow: false).last.try(:note)
    #   tmp.blank? ? nil : tmp
    # end
    if self.invoice_references.blank?
      self.notes_payment
    else
      tmp = self.invoice_references.last.try(:note)
      tmp.blank? ? nil : tmp
    end
  end
  
  def invoice_no
    self.no_invoice
  end

  def is_canceled?
    is_cancel == 1
  end

  def is_uncanceled?
    not is_canceled?
  end

  def is_open?
    status == 0
  end

  def is_closed?
    status == 1
  end

  def is_printed?
    status == 3
  end

  def is_payment_open?
    # status_payment == 0
    payment_status == 0
  end

  def is_payment_closed?
    # status_payment == 1
    payment_status == 1
  end

  def invoice_no_with_status
    str = self.invoice_no
    str += " (Cancel)" if self.is_canceled?
    str
  end

	def generate_invoice_number
		new_number = ""

    # if shipping_instruction.vessels.any?
    #   first_vessel = shipping_instruction.vessels.first
    #   year = first_vessel.etd_date.strftime("%y")
    # Revisi 19 Jan 2015
    if shipping_instruction
      year = shipping_instruction.si_no.to_s[3..4]
    else
      year = Date.today.strftime("%y")
    end

		# inv_count = Invoice.where("YEAR(created_at) = ?", Date.today.year).count
		# year = Date.today.year.to_s[2..3]
    inv_count = Invoice.where("no_invoice LIKE ?", "IBLINV#{year}%").count

		if(inv_count == 0)
			total = 10001.to_s

			new_number = "IBLINV#{year}" + total[1..total.length-1]
		else
			sum = 10000
      last_invoice = Invoice.where("no_invoice LIKE ?", "IBLINV#{year}%").order(no_invoice: :asc).last.no_invoice
			# last_invoice = Invoice.where("YEAR(created_at) = ?", Date.today.year).last.no_invoice
			count = last_invoice[8..last_invoice.length-1].to_i

			while sum <= count + 1
				sum = sum * 10
			end

			total = (sum + count + 1).to_s

			new_number = "IBLINV#{year}" + total[1..total.length-1]
		end
		new_number
	end

  def self.initialize_new(params)
    bl = BillOfLading.find(params[:bid])
    si = bl.shipping_instruction

    json_result = si.is_complete
    array_result = json_result.to_a
    if array_result[0][1]
      vessel = si.vessels.first
      details = []
      
      services = BLServices.new(bl)

      @invoice = Invoice.new(
        :bill_of_lading_id => bl.id, 
        :invoice_date => Date.today, 
        :due_date => vessel.etd_date + si.shipper.credit_term.to_i,
        :to_shipper => si.shipper.company_name, 
        :vessel => si.feeder_vessel,
        :port_of_loading => si.port_of_loading, 
        :destination => si.final_destination, 
        :bl_no => si.master_bl_no,
        :ibl_no => si.si_no,
        :shipper_ref => si.shipper_reference, 
        :etd => si.vessels.first.etd_date,
        :eta => si.vessels.last.eta_date,
        :head_letter => params[:letter].upcase, 
        # :invoice_details_attributes => details

        :currency_code => params[:currency_code].upcase,
      )
      @invoice.no_invoice = @invoice.generate_invoice_number
      # (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
      
      items = []
      unless params[:iid].blank?
        inv = BillOfLadingInvoice.find(params[:iid])
        unless inv.bill_of_lading_items.blank?
          inv.bill_of_lading_items.each do |item|
            items << { description: item.description, amount: item.amount(params[:currency_code].upcase), volume: item.volume }
          end
        end
      end

      if items.blank?
        (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
      else
        @invoice.invoice_details.build(items)
      end

      render :json => {'success' => true, 'message' => render_to_string(:action => "new",:layout => false)}.to_json and return
    else
      output = {
        'success' => false, 
        'message' => "Please complete SI data, Thanks. Go to <a href=\"#{ edit_shipping_instruction_path(si) }\">Update SI</a>",
        'errors' => array_result[1][1]
      }
      render :json => output.to_json and return
    end
  end

  def default_total_include_vat
    (self.default_total_amount.to_f + self.default_vat_10.to_f + self.default_vat_1.to_f).round(2)
  end
  
  def default_total_after_pph_23
    (self.default_total_include_vat.to_f + self.default_pph_23.to_f).round(2)
  end

  def add_vat_10_tax
    '1' if self.vat_10.to_f == 0
  end

  def add_vat_1_tax
    '1' if self.vat_1.to_f == 0
  end

  def add_pph_23_tax
    '1' if self.pph_23.to_f == 0
  end

  def vat_10_tax
    self.vat_10.to_f == 0 ? self.vat_10_2.to_f : self.vat_10.to_f
  end

  def vat_1_tax
    self.vat_1.to_f == 0 ? self.vat_1_2.to_f : self.vat_1.to_f
  end

  def pph_23_tax
    self.pph_23.to_f == 0 ? self.pph_23_2.to_f : self.pph_23.to_f
  end

  def shipper
    self.shipper_company_name
  end

  def shipper_company_name
    self.to_shipper
  end

  def shipper_reference
    self.shipper_ref
  end

  def master_bl_no
    self.bl_no
  end

  def final_destination
    self.destination
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

          # close = PaymentCloseDeposit.where(carrier_id: params[:carrier_id], ibl_ref: ibl_ref, payment_type: params[:payment_type])
          # amount_close = close.blank? ? 0 : close.first.amount.to_f
          # deposit_balance -= amount_close

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

  def is_close_payment?
    # (self.invoice_references.blank?) || (self.is_payment_open? && self.is_uncanceled? && !self.shipping_instruction.is_cr_completed?)
    # self.is_payment_open? && self.is_uncanceled? && !self.shipping_instruction.is_cr_completed? && self.invoice_inquiry.blank?
    self.is_payment_open? && self.is_uncanceled? && self.invoice_inquiry.blank?
  end

  def is_editable_invoice?
    !(self.is_payment_closed? || self.shipping_instruction.is_cr_completed?)
  end

  def paid_month
    self.payment_date if self.is_payment_closed?
  end

  def has_due_date_invoice?
    has_monitoring = false
    # unless self.due_date.blank?
    #   has_monitoring = true if ((self.due_date + 3.days) <= DateTime.now.in_time_zone("Jakarta").to_date) && self.is_payment_open? && self.is_uncanceled?
    # end
    # has_monitoring = true if self.is_payment_open? && self.is_uncanceled?
    unless self.due_date.blank?
      has_monitoring = true if (DateTime.now.in_time_zone("Jakarta").to_date - self.due_date).to_i > 0 && self.is_payment_open? && self.is_uncanceled?
    end
    has_monitoring = false if self.shipping_instruction.is_canceled? || self.shipping_instruction.is_shadow
    has_monitoring
  end

  def is_paid_report?
    self.is_payment_closed? && !self.invoice_inquiry.try(:close_ref).blank?
  end

  private
  def generate_workers
    # InvoiceMonitoringWorker.perform_async(self.shipping_instruction.id)
  end
end
