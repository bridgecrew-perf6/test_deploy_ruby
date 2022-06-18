class BillOfLading < ActiveRecord::Base
  UNCANCELED = 0.freeze
  CANCELED = 1.freeze

  with_options touch: true do |assoc|
    assoc.belongs_to :shipper
    assoc.belongs_to :consignee
    assoc.belongs_to :shipping_instruction
  end

  with_options dependent: :destroy do |assoc|
    assoc.has_one :cost_revenue, through: :shipping_instruction
    assoc.has_many :bill_of_lading_invoices, through: :shipping_instruction
    assoc.has_many :invoices
    assoc.has_many :debit_notes
    assoc.has_many :notes
    assoc.has_many :bill_of_lading_histories
    assoc.has_many :trackings
    assoc.has_many :attachments, :as => :assetable
    # assoc.has_many :bill_of_lading_items
    assoc.has_many :payment_references, foreign_key: 'ibl_ref', primary_key: 'bl_number'
    assoc.has_many :payments, through: :payment_references
  end

  accepts_nested_attributes_for :attachments, :reject_if => lambda { |a| a[:name].blank? || a[:asset].blank? }, :allow_destroy => true
  # accepts_nested_attributes_for :bill_of_lading_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :bill_of_lading_invoices
  
  delegate :si_date, :carrier, :volume, :order_type_text, :first_etd_date, :status, to: :shipping_instruction, allow_nil: true

  scope :recent, -> {
    # includes(:invoices, :debit_notes, :notes, {shipping_instruction: [{si_containers: [:container]}]}, :consignee,
    #          :shipper)
    # .references(:invoices, :debit_notes, :notes, {shipping_instruction: [{si_containers: [:container]}]}, :consignee,
    #             :shipper)
    order("bill_of_ladings.bl_number DESC")
  }

  before_save :uppercase_fields
  after_commit :generate_workers

  search_syntax do
    search_by :text do |scope, phrases|
      columns = [:bl_number, :master_bl_no, :shipper_name, :consignee_name, :notify_party, :final_destination,
                 :port_of_loading, "invoices.no_invoice", "debit_notes.no_dbn", "notes.no_note",
                 "shipping_instructions.order_details"]
      scope.where_like(columns => phrases)
    end
  end
  # validates_uniqueness_of :bl_number, :message => "must be unique"

  def initialize_new(sid)
    shipping_instruction = ShippingInstruction.find(sid)

    self.shipping_instruction_id = shipping_instruction.id
    self.bl_number = shipping_instruction.si_no

    attr_keys = ["shipper_id", "consignee_id", "shipper_name", "consignee_name",
                 "notify_party", "country_of_origin", "place_of_receipt", "port_of_loading",
                 "port_of_discharge", "final_destination", "feeder_vessel", "marks_no",
                 "description_packages", "gw", "measurement", "freight", "freight_details",
                 "shipper_reference", "master_bl_no"]

    attr_keys.each { |attr| self.send("#{attr}=", shipping_instruction.send(attr)) }

    if !shipping_instruction.container_no.nil? && !shipping_instruction.container_no_2.nil?
      self.container_no = "#{shipping_instruction.container_no}\n#{shipping_instruction.container_no_2}"
    elsif !shipping_instruction.container_no.nil?
      self.container_no = shipping_instruction.container_no
    end

    self.freight = "FREIGHT PREPAID \nFCL - FCL" if self.freight.to_s.empty?
    self.special_clause = "Received by the carrier the goods as specified above in apparent good order and condition ,
unless otherwise stated, to be transported to such place as agreed, authorized or permitted herein and subject to all
the terms and conditions appearing on the front and reverse of this Bill of Lading to which the merchant agrees by
accepting this Bill of Lading any local privileges and customs notwithstanding. The particulars given above are as
stated by the shipper and the weight, measurement, quantity, condition and value of the goods are unknown to the
carrier. One of the original Bill of Lading shall be represented to the carrier or his agent at destination before
the cargo be released."

    self.no_of_obl = "THREE (3)"
    self.place_of_issue = "JAKARTA"#shipping_instruction.place_of_receipt
    self.date_of_issue = shipping_instruction.vessels.first.etd_date if shipping_instruction.vessels.any?

    if !self.date_of_issue.nil? && !self.feeder_vessel.nil?
      self.shipped_on_board = "#{self.feeder_vessel} AT TG. PRIOK, JAKARTA, INDONESIA\nDATE : #{self
      .normal_date_format(self.date_of_issue)}"
    end

    if shipping_instruction.gw.blank? || shipping_instruction.gw == "0.00 KGS"
      self.gw = ""
    else
      self.gw = shipping_instruction.gw.split(" KGS")[0]
    end
    if shipping_instruction.measurement.blank? || shipping_instruction.measurement == "0.000 M3"
      self.measurement = ""
    else
      self.measurement = shipping_instruction.measurement.split(" M3")[0]
    end
  end

  def initialize_new_part_bl
    self.bl_number = self.new_shadow_no
    self.is_shadow = true
  end

  def create_part_bl(user)
    self.create_by = user.id
    self.update_by = user.id

    while BillOfLading.exists? bl_number: self.bl_number do
      self.bl_number = self.new_shadow_no
    end

    save
  end

  def update_and_create_history(params, user)
    self.assign_attributes(params)
    if valid?
      bl_history = BillOfLadingHistory.new
      bl_history.populate_data(self)

      if changed?
        self.update_by = user.id
        bl_history.save
      end
    end

    save
  end

  def uppercase_fields
    self.attributes.each do |key, value|
      if key != 'special_clause'
        self.attributes[key] = value.to_s.upcase!
      end
    end
    # self.special_clause = self.special_clause.capitalize
  end

  # def shipper_name
  # 	unless self.shipper_id.nil?
  # 		# address_custom_fields = self.shipper.custom_fields.where(:field_key => "address") unless self.shipper_id.nil?
  # 		shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
  # 		# shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
  # 		shipper_name += self.shipper.full_address unless self.shipper_id.nil?
  # 	end
  # end

  # def consignee_name
  # 	unless self.consignee_id.nil?
  # 		consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
  # 		consignee_name += self.consignee.full_address unless self.consignee_id.nil?
  # 	end
  # end

  def update_shipper_name
    unless self.shipper_id.nil?
      # address_custom_fields = self.shipper.custom_fields.where(:field_key => "address") unless self.shipper_id.nil?
      tmp_shipper_name = self.shipper.company_name + "\n" unless self.shipper_id.nil?
      # shipper_name += address_custom_fields.first.field_value if address_custom_fields.any?
      tmp_shipper_name += self.shipper.full_address unless self.shipper_id.nil?
      self.shipper_name = tmp_shipper_name
    end
  end

  def update_consignee_name
    unless self.consignee_id.nil?
      tmp_consignee_name = self.consignee.company_name + "\n" unless self.consignee_id.nil?
      tmp_consignee_name += self.consignee.full_address unless self.consignee_id.nil?
      self.consignee_name = tmp_consignee_name
    end
  end

  def normal_date_format(date_str)
    date_str.to_time.strftime('%d %B %Y') unless date_str.nil?
  end

  def new_shadow_no
    new_number = ""
    bl_number = (self.is_shadow ? self.bl_number[0..self.bl_number.length-2] : self.bl_number)
    bl_count = BillOfLading.where("bl_number LIKE ? AND is_shadow = ?", "%#{self.bl_number}%", true).count
    if bl_count == 0
      new_number = bl_number + "A"
    else
      new_number = bl_number + (65 + bl_count).chr
    end
    new_number
  end

  def self.with_filter(params)
    # if params[:SI].to_s.empty?
    #   bill_of_lading = BillOfLading.includes(:invoices, :shipper, :consignee, :debit_notes, :notes, :payments, cost_revenue: [ :cost_revenue_items ], shipping_instruction: [ :vessels, si_containers: [ :container ] ]).recent
    #   bill_of_lading = bill_of_lading.search(params[:query]) unless params[:query].to_s.empty?
    #   bill_of_lading = bill_of_lading.where(is_cancel: 1) if params[:cancel].to_i == 1
    #   bill_of_lading = bill_of_lading.where("shipping_instructions.status = 1") if params[:closed].to_i == 1
    #   # bill_of_lading = bill_of_lading.page(params[:page])
    # else
    #   arr_si = params[:SI].split(",")
    #   shipping_instruction = ShippingInstruction.where(si_no: arr_si)
    #   bill_of_lading = BillOfLading.references(:invoices, :debit_notes)
    #   .where(shipping_instruction_id: shipping_instruction).where.not(master_bl_no: "").order(:bl_number)
    # end
    
    # bill_of_ladings = BillOfLading.includes(:invoices, :shipper, :consignee, :debit_notes, :notes, :payments, cost_revenue: [ :cost_revenue_items ], shipping_instruction: [ :vessels, si_containers: [ :container ] ]).all.recent
    bill_of_ladings = BillOfLading.includes(:shipping_instruction).recent

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      bill_of_ladings = bill_of_ladings.where("bl_number LIKE ?", "IBL#{year.to_s[2..3]}%")
    end

    begin
      if Rails.env.development?
        bill_of_ladings.first(10)
      else
        bill_of_ladings
      end
    rescue => e
      bill_of_ladings = BillOfLading.none
    end
  end

  # Revisi 1 Dec 2015
  def delivery_doc_status
    self.delivery_doc? ? 'Done' : 'Not Yet'
  end

  def shipper_company_name
    self.shipper.company_name unless self.shipper.nil?
  end

  def consignee_company_name
    self.consignee.company_name unless self.consignee.nil?
  end

  def first_line_notify_party
    self.notify_party.lines.first.squish unless self.notify_party.blank?
  end

  def ibl_ref
    self.bl_number
  end

  def payment_no
    # payment = PaymentReference.payment_no(self.bl_number)
    # payment.blank? ? "No Payment Yet" : payment.join("<br>")
    self.payments.blank? ? ["No Payment Yet"] : self.payments.map(&:payment_no_with_status)
  end

  def invoice_no
    invoices = []
    self.invoices.each { |inv| invoices << inv.invoice_no_with_status }
    self.debit_notes.each { |inv| invoices << inv.invoice_no_with_status }
    self.notes.each { |inv| invoices << inv.invoice_no_with_status }
    invoices.blank? ? ["No Invoice Yet"] : invoices
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

  def ibl_ref_with_status
    str = self.bl_number
    # str += " (Closed)" if self.is_closed?
    str += " (Cancel BL)" if self.is_canceled?
    str += " (Cancel SI)" if self.shipping_instruction.is_canceled?
    str += " (Closed CR)" if self.shipping_instruction.is_closed?
    if self.cost_revenue.blank?
      str+= " (No Status CR)"
    else
      str += " (Open CR)" if self.cost_revenue.is_open?
    end
    str
  end

  private
  def generate_workers
    unless is_shadow?
      # Do not need to perform si_monitoring, it's will trigger by touch options on associations
      # SiMonitoringWorker.perform_async(shipping_instruction_id)
      # BlMonitoringWorker.perform_async(id)
      # DocumentMonitoringWorker.perform_async(shipping_instruction.id)
    end
  end
end
