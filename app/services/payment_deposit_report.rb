class PaymentDepositReport
  include ActiveModel::Model
  include ActiveModel::Validations

  mattr_accessor :row_ids, :columns, :ibl_refs, :carrier_ids, :payment_types
  attr_accessor :format, :monthly, :from, :to

  validates_presence_of :row_ids, :columns, :format
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
  	tmp = "Payment Deposit"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += "From: #{self.from} " unless self.from.blank?
    # tmp += "To: #{self.to} " unless self.from.blank?
    tmp.upcase
  end

  def title
    tmp = "Payment Deposit"
    # tmp += " #{self.monthly}" unless self.monthly.blank?
    # tmp += " From: #{self.from}" unless self.from.blank?
    # tmp += " To: #{self.to}" unless self.from.blank?
    tmp.upcase
  end

  # def populate_data
  #   # row_ids = self.row_ids

  #   data = []
  #   # data = PaymentDeposit.includes(:payment, :shipping_instruction).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
  #   # data = ShippingInstruction.includes(:payment_deposits, payment_references: [:payment]).where(id: row_ids).order("FIELD(id, #{row_ids.join(',')})")
  
  #   ibl_refs = self.ibl_refs
  #   carrier_ids = self.carrier_ids
  #   payment_types = self.payment_types

  #   params = {}
  #   index = 0
  #   carrier_ids.each do |carrier|
  #     params[carrier] = [] if params[carrier].blank?
  #     params[carrier].push ibl_refs[index]
  #     index+=1
  #   end

  #   data1 = PaymentReference.includes(:payment, :shipping_instruction).where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > ?", 0).references(:payment, :shipping_instruction)
  #   data2 = PaymentDeposit.includes(:payment, :shipping_instruction).references(:payment, :shipping_instruction)
  #   tmp = {}
  #   params.each do |key, value|
  #     # tmp[key] = []
  #     # raise value.inspect
  #     # tmp[key] = [data1.where("payments.carrier_id = ?", key).where(ibl_ref: value).order("FIELD(ibl_ref, #{value.join(',')})"), data2.where("payments.carrier_id = ?", key).where(ibl_deposit: value)]
  #     tmp[key] = []      
  #     value.each do |v|
  #       sort_data = data1.where("payments.carrier_id = ?", key).where(ibl_ref: v) + data2.where("payments.carrier_id = ?", key).where(ibl_deposit: v)
  #       sort_data.sort_by{|a| a.payment_no.split('/')[0].to_i}
  #       tmp[key].push sort_data
  #     end
  #   end
  #   # raise tmp.inspect
  #   # raise params.inspect
  #   tmp
  # end
  
  def populate_data
    data = []
    
    ibl_refs = self.ibl_refs
    carrier_ids = self.carrier_ids
    payment_types = self.payment_types

    params = {}
    index = 0
    carrier_ids.each do |carrier|
      params[carrier] = [] if params[carrier].blank?
      params[carrier].push [ibl_refs[index], payment_types[index]]
      index+=1
    end

    data1 = PaymentReference.includes(:payment, :shipping_instruction).where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > ?", 0).references(:payment, :shipping_instruction)
    data2 = PaymentDeposit.includes(:payment, :shipping_instruction).references(:payment, :shipping_instruction)

    data1 = data1.where("payments.is_cancel = ?", 0)
    data2 = data2.where("payments.is_cancel = ?", 0)

    tmp = {}
    index = 0
    params.each do |key, value|
      # tmp[key] = []
      # raise value.inspect
      # tmp[key] = [data1.where("payments.carrier_id = ?", key).where(ibl_ref: value).order("FIELD(ibl_ref, #{value.join(',')})"), data2.where("payments.carrier_id = ?", key).where(ibl_deposit: value)]
      tmp[key] = []      
      value.each do |v|
        sort_data = data1.where("payments.carrier_id = ? AND payments.payment_type = ?", key, v[1]).where(ibl_ref: v[0]) + data2.where("payments.carrier_id = ? AND payments.payment_type = ?", key, v[1]).where(ibl_deposit: v[0])
        # sort_data.sort_by{|a| a.payment_no.split('/')[0].to_i}
        
        sort_data += PaymentCloseDeposit.where(carrier_id: key, ibl_ref: v[0], payment_type: v[1])
        sort_data.sort_by{|a| a.payment_date}
        
        tmp[key].push sort_data
      end
      index+=1
    end
    tmp
  end

  def template
    "payment_deposit_report"
  end
end
