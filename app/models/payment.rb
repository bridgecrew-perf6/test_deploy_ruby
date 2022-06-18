class Payment < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :no_invoice, :si_no, :bl_number

  belongs_to :carrier_bank, touch: true
  belongs_to :carrier, touch: true
  # has_many :payment_histories, :dependent => :destroy
  # has_many :invoices, :through => :payment_histories
  has_many :payment_references, :dependent => :destroy, :inverse_of => :payment

  has_many :payment_invoices, :dependent => :destroy

  has_many :payment_deposits, :dependent => :destroy, :inverse_of => :payment
  has_many :payment_taxes, :dependent => :destroy, :inverse_of => :payment

  # accepts_nested_attributes_for :payment_references, :reject_if => lambda { |a| a[:ibl_ref].blank? || a[:ibl_ref].nil? ||
  #     a[:amount].blank? || a[:amount].nil? }, :allow_destroy => true
  #|| a[:booking_no].blank? || a[:booking_no].nil?

  accepts_nested_attributes_for :payment_invoices, :reject_if => lambda { |a| a[:payment_date].blank? || a[:carrier].blank? }, :allow_destroy => true

  accepts_nested_attributes_for :payment_references, :reject_if => lambda { |a| a[:ibl_ref].blank? || a[:ibl_ref].nil? ||
      a[:amount].blank? || a[:amount].nil? }, :allow_destroy => true
  accepts_nested_attributes_for :payment_deposits, :reject_if => lambda { |a| a[:ibl_deposit].blank? || a[:ibl_ref].blank? ||
      a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :payment_taxes, :reject_if => lambda { |a| a[:ibl_ref].blank? ||
      a[:amount].blank? }, :allow_destroy => true

  validates_presence_of :payment_type, :carrier_id, :carrier_bank_id, :message => "must be selected"
  validates_presence_of :payment_no, :payment_date, :amount, :payment_references, :message => "can't be blank"
  # validates_presence_of :cash_carrier_name, :if => proc { |obj| self.carrier_bank_id.to_i < 1 }
  # validates_associated :payment_references

  scope :recent, -> {
    # references({payment_references: [{shipping_instruction: [:vessels, :shipper, {si_containers: [:container]}]}]},
    #            {carrier_bank: [:carrier]})
    # .includes({payment_references: [{shipping_instruction: [:vessels, :shipper, {si_containers: [:container]}]}]},
    #           {carrier_bank: [:carrier]})
    # order(payment_no: :desc)
    order(id: :desc)
  }

  validate :compare_invoice_with_estimate

  before_validation :check_cr_completed

  before_validation :check_input_amount

  # validate :check_total_comparison_and_invoice

  # def compare_invoice_with_estimate
  #   self.payment_references.each do |reference|
  #     if !reference.marked_for_destruction?
  #       # amount_estimate = reference.amount_estimate_without_use_deposit + self.check_amount_use_deposit(reference.ibl_ref)
  #       amount_use_deposit = 0
  #       # raise self.payment_deposits.inspect
  #       self.payment_deposits.each do |reference2|
  #         # if !reference2.marked_for_destruction?
  #         if reference2._destroy.blank?
  #           amount_use_deposit += reference2.amount.to_f if (reference2.ibl_ref == reference.ibl_ref)
  #         else
  #           raise self.payment_deposits.inspect 
  #         end
  #       end

  #       amount_estimate = reference.amount.to_f - reference.amount_misc.to_f - reference.amount_overpaid.to_f + amount_use_deposit
  #       unless amount_estimate == reference.amount_invoice
  #         # errors.add(:base, "Reference #{reference.ibl_ref} can't request #{reference.amount_estimate_without_use_deposit} + #{amount_use_deposit} #{reference.amount_invoice}")
  #         # errors.add(:base, "Reference #{reference.ibl_ref} can't request #{reference.amount_estimate_without_use_deposit} + #{self.check_amount_use_deposit(reference.ibl_ref)} #{reference.amount_invoice}")
  #         errors.add(:base, "Reference #{reference.ibl_ref} can't request #{amount_estimate} != #{reference.amount_invoice}")
  #         # return
  #       end
  #     end
  #   end
  # end

  def compare_invoice_with_estimate
    valid_amount = true
    deposit = {}
    use_deposit = {}
    self.payment_deposits.each do |value|
      unless value.marked_for_destruction?
        if deposit[value.ibl_ref.upcase].blank?
          deposit[value.ibl_ref.upcase] = value.amount.to_f
        else
          deposit[value.ibl_ref.upcase] += value.amount.to_f
        end

        if use_deposit[value.ibl_deposit.upcase].blank?
          use_deposit[value.ibl_deposit.upcase] = value.amount.to_f
        else
          use_deposit[value.ibl_deposit.upcase] += value.amount.to_f
        end
        if valid_amount && value.amount.to_f < 0
          errors.add(:base, "Amount isn't valid")
          valid_amount = false
        end
      end
    end

    self.payment_references.each do |value|
      unless value.marked_for_destruction?
        amount_estimate = (value.amount.to_f - value.amount_misc.to_f - value.amount_overpaid.to_f + deposit[value.ibl_ref.upcase].to_f).round(2)
        deposit[value.ibl_ref.upcase] = 0

        unless amount_estimate == value.amount_invoice.to_f && (amount_estimate != 0 && value.amount_invoice.to_f != 0)
          # errors.add(:base, "Reference #{value.ibl_ref} can't request #{amount_estimate} != #{value.amount_invoice}")
          errors.add(:base, "Reference #{value.ibl_ref} can't request")
        end

        if valid_amount && (value.amount.to_f < 0 || value.amount_overpaid.to_f < 0 || value.amount_invoice.to_f < 0) 
          errors.add(:base, "Amount isn't valid")
          valid_amount = false
        end
      end
    end

    deposit.each do |key, value|
      if value.to_f != 0
        errors.add(:base, "Use Deposit for #{key} can't request")
      end
    end

    use_deposit.each do |key, value|
      if value.to_f > check_amount_use_deposit(key)
        # errors.add(:base, "Balance IBL Deposit #{key} isn't sufficient #{value.to_f} #{check_amount_use_deposit(key)}")
        errors.add(:base, "Balance IBL Deposit #{key} isn't sufficient")
      end
    end
  end

  def check_cr_completed
    self.payment_references.each do |value|
      si = ShippingInstruction.find_by(si_no: value.ibl_ref)
      if si.is_cr_completed?
        if value.changed?
          errors.add(:base, "Reference #{value.ibl_ref} can't updated")
        end
        if value.marked_for_destruction?
          errors.add(:base, "Reference #{value.ibl_ref} can't destroyed")
        end
        value.reload
      end
    end
  end

  def check_amount_use_deposit(ibl_ref)
    carrier_id = self.carrier_id
    currency = self.currency
    payment_references = PaymentReference.includes(:payment).where.not(amount_invoice: nil, amount_overpaid: nil).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_references.ibl_ref = ?", currency, carrier_id, ibl_ref).references(:payment)
    payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_deposits.ibl_deposit = ?", currency, carrier_id, ibl_ref).references(:payment)
    
    unless self.new_record?
      payment_references = payment_references.where.not("payments.id = ?", self.id)
      payment_deposits = payment_deposits.where.not("payments.id = ?", self.id)
    end
    overpaid = payment_references.map{|p| p.amount_overpaid}.sum(&:to_f)
    deposit = payment_deposits.map{|p| p.amount}.sum(&:to_f)

    (overpaid - deposit).round(2)
  end

  search_syntax do
    search_by :text do |scope, phrases|
      columns = [:payment_no, :notes, :payment_date, "payment_references.ibl_ref", "payment_references.booking_no",
                 "shipping_instructions.shipper_name", "shipping_instructions.final_destination", "carriers.name",
                 "payment_references.amount", "vessels.etd_date"]
      scope.where_like(columns => phrases)
    end
  end

  #after_save :save_assocation

  # def initialize_new
  #   self.payment_date = Time.now
  #   self.carrier_bank_id = 0
  #   self.amount = 0
  # end

  def initialize_new(params)
    self.payment_date = Time.now
    # self.carrier_bank_id = 0
    # self.amount = 0
    unless params[:carrier].blank?
      carrier = Carrier.find_by(name: params[:carrier])
      self.carrier_id = carrier.id unless carrier.blank?
    end
    # self.carrier_id = params[:carrier_id] if params[:ibl_ref]
    unless params[:ibl_ref].blank?
      si = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      self.payment_references.build(ibl_ref: si.ibl_ref, master_bl_no: si.master_bl_no) unless si.blank?
    end
  end

  def generate_number(code, year = Date.today.year)
    self.class.generate_number(code, year)
    # payment_code = "%/#{code}/#{year}"
    # if Payment.where("payment_no LIKE ?", payment_code).count == 0
    #   new_number = "001/#{code}/#{year.to_s}"
    # else
    #   last_auto_num = Payment.where("payment_no LIKE ?", payment_code).last.payment_no
    #   count = last_auto_num[0..last_auto_num.index('/')-1].to_i
    #   new_number = ""
    #   sum = 1000
    #   while sum <= count + 1
    #     sum = sum * 10
    #   end

    #   total = (sum + count + 1).to_s
    #   new_number = "#{total[1..total.length-1]}/#{code}/#{year.to_s}"
    # end
    # last_auto_num = Payment.where("payment_no LIKE ? AND YEAR(created_at) = ?", "%" + code + "%", Time.now.year).last.payment_no
    # count = last_auto_num[0..last_auto_num.index('/')-1].to_i
    # new_number = ""
    # if count
    # 	sum = 1000
    # 	while sum <= count + 1
    # 		sum = sum * 10
    # 	end

    # 	total = (sum + count + 1).to_s
    # 	new_number = "#{total[1..total.length-1]}/#{code}/#{Time.now.year.to_s}"
    # else
    # 	new_number = "001/#{code}/#{Time.now.year.to_s}"
    # end
    # new_number
  end

  def self.generate_number(code, year = Date.today.year)
    payment_code = "%/#{code}/#{year}"
    if Payment.where("payment_no LIKE ?", payment_code).count == 0
      new_number = "001/#{code}/#{year.to_s}"
    else
      last_auto_num = Payment.where("payment_no LIKE ?", payment_code).last.payment_no
      count = last_auto_num[0..last_auto_num.index('/')-1].to_i
      new_number = ""
      sum = 1000
      while sum <= count + 1
        sum = sum * 10
      end

      total = (sum + count + 1).to_s
      new_number = "#{total[1..total.length-1]}/#{code}/#{year.to_s}"
    end
    # last_auto_num = Payment.where("payment_no LIKE ? AND YEAR(created_at) = ?", "%" + code + "%", Time.now.year).last.payment_no
    # count = last_auto_num[0..last_auto_num.index('/')-1].to_i
    # new_number = ""
    # if count
    # 	sum = 1000
    # 	while sum <= count + 1
    # 		sum = sum * 10
    # 	end

    # 	total = (sum + count + 1).to_s
    # 	new_number = "#{total[1..total.length-1]}/#{code}/#{Time.now.year.to_s}"
    # else
    # 	new_number = "001/#{code}/#{Time.now.year.to_s}"
    # end
    return new_number
  end

  def check_input_amount
    # if self.amount == 0
    if self.amount.blank?
      self.errors.add :amount, "can't be zero"
      false
    end

    # invoice = Invoice.find(self.invoice_id)
    # total_payment = invoice.payments.sum(:amount) + self.amount

    # if(invoice.total_invoice < total_payment)
    # 	self.errors.add :amount, "of payment exceeds the credit"
    # 	return false
    # end
    # return true
  end

  # def save_assocation
  # 	inv_arr = self.no_invoice.split(",")
  # 	invoices = Invoice.where(no_invoice: inv_arr).all

  # 	invoices.each do |inv|
  # 		history = PaymentHistory.where(payment_id: self.id, invoice_id: inv.id)

  # 		if not history.any?
  # 			history = PaymentHistory.new
  # 			history.payment_id = self.id
  # 			history.invoice_id = inv.id
  # 			history.save
  # 		end
  # 	end
  # end

  def status_info
    if self.is_canceled?
      "Cancel"
    else
      if self.status == 1
        "Sent"
      elsif self.status == 0
        "Open"
      end
    end 
  end

  def status_text
    if self.status == 0
      "Open"
    elsif self.status == 1
      "Sent"
    end
  end

  def create!(year = Date.today.year)
    while Payment.exists? payment_no: self.payment_no do
      code = (self.payment_no.include?("USD") ? "USD" : "IDR")
      self.payment_no = self.generate_number(code, year)
    end

    save
  end

  def self.with_filter(params)
    # payments = Payment.includes(carrier_bank: [ :carrier ], payment_references: [ shipping_instruction: [ :shipper, :vessels, si_containers: [ :container ] ] ]).recent
    # payments = payments.search(params[:query]) unless params[:query].to_s.empty?
    # payments = payments.where(status: params[:status]) unless params[:status].to_s.empty?
    # payments = payments.where(is_cancel: 1) if params[:cancel].to_i == 1
    # payments = payments.where(payment_type: params[:sort]) unless params[:sort].to_s.empty?

    payments = Payment.includes(:payment_references).recent

    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      payments = payments.where("payment_no LIKE ?", "%/#{year}")
    end

    # payments#.page(params[:page])
    if Rails.env.development?
      payments.last(10)
    else
      payments
    end
  end

  def self.generate_reports(params)
    payments = Payment.where(payment_type: params[:payment_type])

    begin
      case params[:filter_payments_by]
      when "yearly"
        year = Constant.years_range.include?(params[:filter_payments_yearly].to_i) ? params[:filter_payments_yearly].to_i : Date.today.year
        date = DateTime.new
        date = date.change(year: year)
        payments = payments.where(payment_date: date.at_beginning_of_year..date.end_of_year)
      when "monthly"
        date = Date.parse(params[:filter_payments_monthly])
        payments = payments.where(payment_date: date.at_beginning_of_month..date.end_of_month)
      end
    end 
    
    payments
  end

  def carrier_name
    carrier_name = ""
    if self.carrier_id.blank?
      carrier_name = self.cash_carrier_name
    else
      carrier_name = self.carrier.name unless self.carrier.blank?
    end
    if self.carrier_bank_id == 0
      carrier_name
    elsif self.carrier_bank_id == -1
      carrier_name
    else
      self.carrier_bank.carrier.name
    end
  end

  def carrier_name_with_payment_method
    carrier_name = ""
    if self.carrier_id.blank?
      carrier_name = self.cash_carrier_name
    else
      carrier_name = self.carrier.name unless self.carrier.blank?
    end
    if self.carrier_bank_id == 0
      "Cash by: "+carrier_name
    elsif self.carrier_bank_id == -1
      "Deposit by: "+carrier_name
    else
      self.carrier_bank.carrier.name
    end
  end

  def carrier_bank_name
    if self.carrier_bank_id == 0
      "CASH by: "+self.cash_carrier_name
    elsif self.carrier_bank_id == -1
      "DEPOSIT by: "+self.cash_carrier_name
    else
      self.carrier_bank.carrier_bank_name
    end
  end

  def payment_method
    if self.carrier_bank_id == 0
      "CASH"
    elsif self.carrier_bank_id == -1
      "DEPOSIT"
    else
      "BANK TRANSACTION"
    end
  end

  def currency
    self.payment_no.to_s.include?("USD") ? "USD" : "IDR"
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

  def is_sent?
    status == 1
  end

  def payment_no_with_status
    str = self.payment_no
    str += " (Cancel)" if self.is_canceled?
    str
  end

  # def self.get_ibl_deposit(number, name, type)
  #   if number.to_f > 0
  #     payments = includes(:payment_references).where(carrier_bank_id: number)
  #   else
  #     payments = includes(:payment_references).where(carrier_bank_id: number, cash_carrier_name: name, payment_type: type)
  #   end

  #   if payments.blank?
  #     @get_ibl_deposit = {success: false, message: "SI Not Listed"}
  #   else
  #     data = Array.new();
  #     payments.each do |payment|
  #       payment.payment_references.each do |reference|
  #         if reference.deposit_balance > 0
  #           data.push(
  #             {
  #               ibl_ref: reference.ibl_ref,
  #               deposit_balance: reference.deposit_balance
  #             }
  #           )
  #           # str = [reference.ibl_ref.to_s, reference.deposit_balance.to_s].join(' - ')
  #           # data.push(str)
  #           # data.push(reference.ibl_deposit)
  #         end
  #       end
  #     end
  #     @get_ibl_deposit = begin
  #       if data.nil? || data.blank?
  #         {success: false, message: "No Deposit Balance"}
  #       else
  #         {success: true, ibl_deposit: data}
  #       end
  #     end
  #   end
  #   @get_ibl_deposit
  # end

  # def self.get_ibl_deposit(number, name, type)
  #   if number.to_f > 0
  #     # payment_references = PaymentReference.joins(:payment).where("payments.carrier_bank_id = ? AND payments.payment_type = ?", number, type)
  #     # payment_deposits = PaymentDeposit.joins(:payment).where("payments.carrier_bank_id = ? AND payments.payment_type = ?", number, type)
  #     payment_references = PaymentReference.includes(:payment).where("payments.carrier_bank_id = ? AND payments.payment_type = ?", number, type).references(:payment)
  #     payment_deposits = PaymentDeposit.includes(:payment).where("payments.carrier_bank_id = ? AND payments.payment_type = ?", number, type).references(:payment)
  #   else
  #     # payment_references = PaymentReference.joins(:payment).where("payments.carrier_bank_id = ? AND payments.cash_carrier_name = ? AND payments.payment_type = ?", number, name, type)
  #     # payment_deposits = PaymentDeposit.joins(:payment).where("payments.carrier_bank_id = ? AND payments.cash_carrier_name = ? AND payments.payment_type = ?", number, name, type)
  #     payment_references = PaymentReference.includes(:payment).where("payments.carrier_bank_id = ? AND payments.cash_carrier_name = ? AND payments.payment_type = ?", number, name, type).references(:payment)
  #     payment_deposits = PaymentDeposit.includes(:payment).where("payments.carrier_bank_id = ? AND payments.cash_carrier_name = ? AND payments.payment_type = ?", number, name, type).references(:payment)
  #   end

  #   if payment_references.blank?
  #     @get_ibl_deposit = {success: false, message: "SI Not Listed"}
  #   else
  #     data = []
  #     payment_references.where.not(amount_invoice: nil).where("payment_references.amount_invoice < payment_references.amount").order(ibl_ref: :desc).group_by(&:ibl_ref).each do |ibl_ref, references|
  #       data.push(
  #         {
  #           ibl_ref: ibl_ref,
  #           deposit_balance: references.map{|p| p.amount_deposit}.sum(&:to_f) - payment_deposits.where(ibl_deposit: ibl_ref).map{|p| p.amount}.sum(&:to_f)
  #         }
  #       )
  #     end
  #     @get_ibl_deposit = begin
  #       if data.nil? || data.blank?
  #         {success: false, message: "No Deposit Balance"}
  #       else
  #         {success: true, ibl_deposit: data}
  #       end
  #     end
  #   end
  #   @get_ibl_deposit
  # end

  # def self.get_ibl_deposit(params)
  #   # payment_references = PaymentReference.includes(:payment).where("payments.carrier_bank_id = ? AND payments.payment_type = ?", params[:carrier_bank_id], params[:payment_type]).references(:payment)
  #   # payment_deposits = PaymentDeposit.includes(:payment).where("payments.carrier_bank_id = ? AND payments.payment_type = ?", params[:carrier_bank_id], params[:payment_type]).references(:payment)
  #   # if params[:carrier_bank_id].to_f <= 0
  #   #   unless params[:cash_carrier_name].blank?
  #   #     payment_references = payment_references.where("payments.cash_carrier_name = ?", params[:cash_carrier_name])
  #   #     payment_deposits = payment_deposits.where("payments.cash_carrier_name = ?", params[:cash_carrier_name])
  #   #   end
  #   #   unless params[:carrier_id].blank?
  #   #     payment_references = payment_references.where("payments.carrier_id = ?", params[:carrier_id])
  #   #     payment_deposits = payment_deposits.where("payments.carrier_id = ?", params[:carrier_id])
  #   #   end
  #   # end

  #   payment_references = PaymentReference.includes(:payment).where("payments.payment_type = ?", params[:payment_type]).references(:payment)
  #   payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ?", params[:payment_type]).references(:payment)
  #   unless params[:carrier_id].blank?
  #     payment_references = payment_references.where("payments.carrier_id = ?", params[:carrier_id])
  #     payment_deposits = payment_deposits.where("payments.carrier_id = ?", params[:carrier_id])
  #   end
    
  #   if payment_references.blank?
  #     @get_ibl_deposit = {success: false, message: "Deposit is Empty"}
  #   else
  #     data = []
  #     payment_references.where.not(amount_invoice: nil).where("payment_references.amount_invoice < payment_references.amount").order(ibl_ref: :desc).group_by(&:ibl_ref).each do |ibl_ref, references|
  #       data.push(
  #         {
  #           ibl_ref: ibl_ref,
  #           master_bl_no: references.first.shipping_instruction.master_bl_no,
  #           deposit_balance: references.map{|p| p.amount_deposit}.sum(&:to_f) - payment_deposits.where(ibl_deposit: ibl_ref).map{|p| p.amount}.sum(&:to_f),
  #           payment_type: params[:payment_type]
  #         }
  #       )
  #     end
  #     @get_ibl_deposit = begin
  #       if data.nil? || data.blank?
  #         {success: false, message: "No Deposit Balance"}
  #       else
  #         {success: true, ibl_deposit: data}
  #       end
  #     end
  #   end
  #   @get_ibl_deposit
  # end


  # def self.get_ibl_deposit(params)
  #   if params[:payment_type].blank?
  #     @get_ibl_deposit = {success: false, message: "Select a Payment Type first"}
  #   elsif params[:carrier_id].blank?
  #     @get_ibl_deposit = {success: false, message: "Select a Carrier first"}
  #   else
  #     payment_references = PaymentReference.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ?", params[:payment_type], params[:carrier_id]).references(:payment)
  #     payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ?", params[:payment_type], params[:carrier_id]).references(:payment)
      
  #     if payment_references.blank?
  #       @get_ibl_deposit = {success: false, message: "No Overpaid Payment"}
  #     else
  #       data = []
  #       # payment_references.where.not(amount_invoice: nil).where("payment_references.amount_invoice < payment_references.amount").order(ibl_ref: :desc).group_by(&:ibl_ref).each do |ibl_ref, references|
  #       payment_references.where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > 0").order(ibl_ref: :desc).group_by(&:ibl_ref).each do |ibl_ref, references|
  #         deposit_balance = references.map{|p| p.amount_overpaid}.sum(&:to_f) - payment_deposits.where(ibl_deposit: ibl_ref).map{|p| p.amount}.sum(&:to_f)
  #         data.push(
  #           {
  #             ibl_ref: ibl_ref,
  #             master_bl_no: references.first.shipping_instruction.master_bl_no,
  #             # deposit_balance: references.map{|p| p.amount_deposit}.sum(&:to_f) - payment_deposits.where(ibl_deposit: ibl_ref).map{|p| p.amount}.sum(&:to_f),
  #             deposit_balance: deposit_balance,
  #             payment_type: params[:payment_type]
  #           }
  #         ) if deposit_balance.to_f > 0
  #       end
  #       @get_ibl_deposit = begin
  #         if data.nil? || data.blank?
  #           {success: false, message: "No Deposit Balance"}
  #         else
  #           {success: true, ibl_deposit: data}
  #         end
  #       end
  #     end
  #   end
  #   @get_ibl_deposit
  # end

  def self.get_ibl_deposit(params)
    if params[:payment_type].blank?
      @get_ibl_deposit = {success: false, message: "Select a Payment Type first"}
    elsif params[:carrier_id].blank?
      @get_ibl_deposit = {success: false, message: "Select a Carrier first"}
    else
      payment_references = PaymentReference.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ?", params[:payment_type], params[:carrier_id]).references(:payment)
      payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ?", params[:payment_type], params[:carrier_id]).references(:payment)
    
      payment_references = payment_references.where("payments.is_cancel = ?", 0)
      payment_deposits = payment_deposits.where("payments.is_cancel = ?", 0)
                
      if payment_references.blank?
        @get_ibl_deposit = {success: false, message: "No Overpaid Payment"}
      else
        data = []
        # payment_references.where.not(amount_invoice: nil).where("payment_references.amount_invoice < payment_references.amount").order(ibl_ref: :desc).group_by(&:ibl_ref).each do |ibl_ref, references|
        payment_references.where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > 0").order(ibl_ref: :desc).group_by(&:ibl_ref).each do |ibl_ref, references|
          deposit_balance = references.map{|p| p.amount_overpaid}.sum(&:to_f) - payment_deposits.where(ibl_deposit: ibl_ref).map{|p| p.amount}.sum(&:to_f)

          close = PaymentCloseDeposit.where(carrier_id: params[:carrier_id], ibl_ref: ibl_ref, payment_type: params[:payment_type])
          amount_close = close.blank? ? 0 : close.first.amount.to_f
          deposit_balance -= amount_close

          data.push(
            {
              ibl_ref: ibl_ref,
              master_bl_no: references.first.shipping_instruction.master_bl_no,
              # deposit_balance: references.map{|p| p.amount_deposit}.sum(&:to_f) - payment_deposits.where(ibl_deposit: ibl_ref).map{|p| p.amount}.sum(&:to_f),
              deposit_balance: deposit_balance,
              payment_type: params[:payment_type]
            }
          ) if deposit_balance.to_f > 0
        end
        @get_ibl_deposit = begin
          if data.nil? || data.blank?
            {success: false, message: "No Deposit Balance"}
          else
            {success: true, ibl_deposit: data}
          end
        end
      end
    end
    @get_ibl_deposit
  end

  def self.idr_balance(carrier_id, ibl_ref)
    return if carrier_id.blank?
    payment_references = PaymentReference.includes(:payment).where.not(amount_invoice: nil, amount_overpaid: nil).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_references.ibl_ref = ?", "IDR", carrier_id, ibl_ref).references(:payment)
    payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_deposits.ibl_deposit = ?", "IDR", carrier_id, ibl_ref).references(:payment)
    
    payment_references = payment_references.where("payments.is_cancel = ?", 0)
    payment_deposits = payment_deposits.where("payments.is_cancel = ?", 0)

    overpaid = payment_references.map{|p| p.amount_overpaid}.sum(&:to_f)
    deposit = payment_deposits.map{|p| p.amount}.sum(&:to_f)

    # (overpaid - deposit).round(2)
    si = ShippingInstruction.where(si_no: ibl_ref).first
    close_deposit = PaymentCloseDeposit.where(carrier_id: carrier_id, ibl_ref: ibl_ref, payment_type: "IDR")
    close_deposit = close_deposit.blank? ? 0 : close_deposit.first.amount.to_f
    (overpaid - deposit - close_deposit).round(2)
  end

  def self.usd_balance(carrier_id, ibl_ref)
    return if carrier_id.blank?
    payment_references = PaymentReference.includes(:payment).where.not(amount_invoice: nil, amount_overpaid: nil).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_references.ibl_ref = ?", "USD", carrier_id, ibl_ref).references(:payment)
    payment_deposits = PaymentDeposit.includes(:payment).where("payments.payment_type = ? AND payments.carrier_id = ? AND payment_deposits.ibl_deposit = ?", "USD", carrier_id, ibl_ref).references(:payment)
    
    payment_references = payment_references.where("payments.is_cancel = ?", 0)
    payment_deposits = payment_deposits.where("payments.is_cancel = ?", 0)

    overpaid = payment_references.map{|p| p.amount_overpaid}.sum(&:to_f)
    deposit = payment_deposits.map{|p| p.amount}.sum(&:to_f)

    # (overpaid - deposit).round(2)
    si = ShippingInstruction.where(si_no: ibl_ref).first
    close_deposit = PaymentCloseDeposit.where(carrier_id: carrier_id, ibl_ref: ibl_ref, payment_type: "USD")
    close_deposit = close_deposit.blank? ? 0 : close_deposit.first.amount.to_f
    (overpaid - deposit - close_deposit).round(2)
  end

  def have_deposit_detail?
    valid = false
    self.payment_references.each do |reference|
      valid = true if reference.amount_use_deposit.to_f != 0 || reference.amount_overpaid.to_f != 0
    end
    valid
  end

  def req_no
    "#{self.payment_no.split("/")[0]}/#{self.currency}"
  end

  def no
    self.payment_no.split("/")[0]
  end

  def total_payment
    self.payment_references.map{|p| p.amount unless p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def amount_use_deposit(ibl_ref)
    self.payment_deposits.map{|p| p.amount if p.ibl_ref == ibl_ref && !p.marked_for_destruction?}.sum(&:to_f).round(2)
  end

  def amount_estimate(ibl_ref)
  end

  def have_reference_with_cr_completed?
    valid = false
    self.payment_references.each do |reference|
      valid = true if reference.shipping_instruction.is_cr_completed?
    end
    valid
  end
end