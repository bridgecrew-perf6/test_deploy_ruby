class Note < ActiveRecord::Base
  include UpcaseAttributes
  include ActionView::Helpers::NumberHelper


	# attr_accessor :tipe, :default_total_amount, :default_vat_10, :default_vat_1, :default_total_include_vat, :default_pph_23, :default_total_after_pph_23, :default_rate
  attr_accessor :tipe

	enum status_tax: [ :open, :completed ]

  UNCANCELED = 0.freeze

  CLOSED = 1.freeze
	
  with_options touch: true do |assoc|
  	assoc.belongs_to :bill_of_lading
    assoc.belongs_to :shipping_instruction, foreign_key: 'ibl_no', primary_key: 'si_no'
  end

	# has_many :note_details, :dependent => :destroy
	# accepts_nested_attributes_for :note_details, :reject_if => lambda { |a| a[:description].blank? || a[:description].nil? || 
	# 	a[:amount].blank? || a[:amount].nil? || a[:volume].blank? || a[:volume].nil? }, :allow_destroy => true

	with_options dependent: :destroy do |assoc|
    assoc.has_many :note_details
	
    assoc.has_many :invoice_details, class_name: "NoteDetail", inverse_of: :note

    assoc.has_many :close_payment_histories, class_name: "ClosePayment", foreign_key: 'invoice_no', primary_key: 'no_note'
    
    assoc.has_one :invoice_inquiry, -> { where(is_shadow: false) }, class_name: "ClosePayment", foreign_key: 'invoice_no', primary_key: 'no_note'
    assoc.has_many :invoice_references, class_name: "InvoicePayment", through: :invoice_inquiry
    assoc.has_many :invoice_deposits, class_name: "InvoiceDeposit", through: :invoice_inquiry
  end

	with_options allow_destroy: true do |nest_attr|
  	nest_attr.accepts_nested_attributes_for :note_details, :reject_if => lambda { |a| a[:description].blank? }
	
    # nest_attr.accepts_nested_attributes_for :invoice_payments, :reject_if => lambda { |a| a[:payment_date].blank? }
    nest_attr.accepts_nested_attributes_for :invoice_details, :reject_if => lambda { |a| a[:description].blank? }
  end
  
  delegate :ibl_ref, :ibl_ref_with_status, :first_etd_date, :shipper_company_name, to: :shipping_instruction, allow_nil: true

  scope :uncanceled, -> { where(is_cancel: UNCANCELED) }
  scope :closed, -> { where(status_payment: CLOSED) }
  scope :recent, -> {
    # references(:note_details, bill_of_lading: {shipping_instruction: [:shipper, :vessels, si_containers: [:container]]})
    # .includes(:note_details, bill_of_lading: {shipping_instruction: [:shipper, :vessels, si_containers: [:container]]})
    order(no_note: :desc)
  }
  scope :recent_with_vessels, -> {
    # recent.references({bill_of_lading: {shipping_instruction: [:vessels]}}, :note_details)
    # .includes({bill_of_lading: {shipping_instruction: [:vessels]}}, :note_details)
    joins(:shipping_instruction, "LEFT OUTER JOIN vessels VS ON (VS.id = (SELECT SVS.id FROM vessels SVS WHERE SVS.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
  }
  scope :reports, -> {
    recent.references({shipping_instruction: [:vessels]}, :note_details)
    .includes({shipping_instruction: [:vessels]}, :note_details)
    .joins("LEFT OUTER JOIN vessels VS ON (VS.id = (SELECT SVS.id FROM vessels SVS WHERE SVS.shipping_instruction_id = shipping_instructions.id LIMIT 1))")
  }

  search_syntax do
    search_by :text do |scope, phrases|
      columns = [:no_note, :currency_code, :customer_ori, :to_shipper, :destination,
                 "shipping_instructions.si_no", "shipping_instructions.order_details"]
      scope.where_like(columns => phrases)
    end
  end

	validates_presence_of :currency_code, :customer, :message => "must be selected"
	validates_uniqueness_of :no_note, :message => "must be unique"
	
	# Revisi 1 Dec 2015
	before_create :set_volume
  after_commit :generate_workers

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

  def invoice_no
    self.no_note
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

  def invoice_date
  	self.note_date
  end

  def payment_date
    if self.close_payment_histories.blank?
      self.date_of_payment
    else
      tmp = self.invoice_inquiry.try(:payment_date)
      tmp.blank? ? nil : tmp
    end
  end

  def payment_note
    if self.invoice_references.blank?
      self.notes_payment
    else
      tmp = self.invoice_references.last.try(:note)
      tmp.blank? ? nil : tmp
    end
  end
  
	def generate_note_number
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

		# inv_count = Note.where("YEAR(created_at) = ?", Date.today.year).count
		# year = Date.today.year.to_s[2..3]
    inv_count = Note.where("no_note LIKE ?", "IBLCRN#{year}%").count

		if(inv_count == 0)
			total = 10001.to_s

			new_number = "IBLCRN#{year}" + total[1..total.length-1]
		else
			sum = 10000
      last_invoice = Note.where("no_note LIKE ?", "IBLCRN#{year}%").order(no_note: :asc).last.no_note
			# last_invoice = Note.where("YEAR(created_at) = ?", Date.today.year).last.no_note
			count = last_invoice[8..last_invoice.length-1].to_i

			while sum <= count + 1
				sum = sum * 10
			end

			total = (sum + count + 1).to_s

			new_number = "IBLCRN#{year}" + total[1..total.length-1]
		end
		new_number
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

  def is_close_payment?
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
