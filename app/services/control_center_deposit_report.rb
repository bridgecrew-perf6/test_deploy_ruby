class ControlCenterDepositReport
  include ActiveModel::Model
  include ActiveModel::Validations

  # mattr_accessor :row_ids, :columns, :head_letters
  mattr_accessor :row_ids, :columns, :ibl_refs, :carrier_ids, :payment_types
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Control Center - Deposit"
    tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Control Center - Deposit"
    tmp += " #{self.monthly}" unless self.monthly.blank?
    tmp += " From: #{self.from}" unless self.from.blank?
    tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  # def populate_data
  #   row_ids = self.row_ids

  #   data = []

  #   # # data = InvoicePayment.includes(:invoice).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
  #   # data = InvoicePayment.includes(:close_payment).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
  #   data = InvoicePayment.includes(:close_payment).where(invoice_no: row_ids).order("FIELD(id, #{row_ids.join(',')})")
    
  #   data
  # end
  
  def populate_data
    data = []
    
    row_ids = self.row_ids
    carrier_ids = self.carrier_ids
    payment_types = self.payment_types

    params = {}
    index = 0
    carrier_ids.each do |carrier|
      params[carrier] = [] if params[carrier].blank?
      params[carrier].push [row_ids[index], payment_types[index]]
      index+=1
    end

    data1 = InvoicePayment.includes(:close_payment).where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL").references(:close_payment)
    data2 = InvoiceDeposit.includes(:close_payment).where.not("invoice_deposits.amount IN ('0','') OR invoice_deposits.amount IS NULL").references(:close_payment)

    data1 = data1.where("close_payments.is_shadow = ?", false)
    data2 = data2.where("close_payments.is_shadow = ?", false)

    tmp = {}
    params.each do |key, value|
      tmp[key] = []      
      value.each do |v|
        sort_data = data1.where("close_payments.customer = ? AND invoice_payments.invoice_no = ?", key, v[0]) + data2.where("close_payments.customer = ? AND invoice_deposits.invoice_deposit = ?", key, v[0])
        
        sort_data += InvoiceCloseDeposit.where(invoice_no: v[0])
        sort_data.sort_by{|a| a.payment_date}
      
        tmp[key].push sort_data
      end
      index+=1
    end
    tmp
  end

  def template
    "cc_deposit_report"
  end
end
