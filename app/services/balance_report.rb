class BalanceReport
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :rows, :format, :filter_by, :yearly, :monthly, :from, :to

  validates_presence_of :format, :rows
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def self.initialize_new
    balance = BalanceReport.new
    
    unless Rails.env.development?
      balance.rows = 
      { description: 'Invoice Unpaid', amount_usd: BalanceReport.invoice_unpaid('USD'), amount_idr: BalanceReport.invoice_unpaid('IDR'), disabled: true }, 
      { description: 'Invoice Not Create (Payment Done)', amount_usd: BalanceReport.invoice_not_create("USD"), amount_idr: BalanceReport.invoice_not_create("IDR"), disabled: true }, 
      { description: 'Payment Not Create (Invoice Sent) (-)', amount_usd: BalanceReport.payment_not_create("USD"), amount_idr: BalanceReport.payment_not_create("IDR"), disabled: true }, 
      { description: 'Estimate Add Invoice', amount_idr: BalanceReport.estimate_add_invoice, disabled: true }, 
      { description: 'Estimate Add Payment (-)', amount_idr: BalanceReport.estimate_add_payment, disabled: true }, 
      { description: 'Deposit At Liner', amount_usd: BalanceReport.deposit_at_liner("USD"), amount_idr: BalanceReport.deposit_at_liner("IDR"), disabled: true }, 
      { description: 'Deposit From Shipper (-)', amount_usd: BalanceReport.deposit_from_shipper("USD"), amount_idr: BalanceReport.deposit_from_shipper("IDR"), disabled: true }, 
      { description: 'Shortpaid From Shipper', amount_usd: BalanceReport.shortpaid_from_shipper("USD"), amount_idr: BalanceReport.shortpaid_from_shipper("IDR"), disabled: true }, 
      { description: 'BCA' }, 
      { description: 'Danamon' }, 
      { description: 'Mandiri' }, 
      { description: 'Cimb Niaga' }, 
      { description: 'BII' }, 
      { description: 'Post Date Transfer (Payment To Liner) (-)' }, 
      { description: 'Invoice Wait To Be Closed (Control Centre) (-)' }, 
      { description: 'Petty Cash' },
      { description: 'Account Receivable' },
      { description: 'Account Payable (-)' },
      { description: 'Bad Debt (-)' }
    end
    
    balance 
  end

  def self.invoice_unpaid(currency)
    if Rails.env.development?
      invoices = Invoice.includes(:close_payment_histories, :invoice_inquiry, :invoice_details).where(currency_code: currency)
    else
      invoices = Invoice.includes(:close_payment_histories, :invoice_inquiry, :invoice_details).where(currency_code: currency)
      debit_notes = DebitNote.includes(:close_payment_histories, :invoice_inquiry, :invoice_details).where(currency_code: currency)
      notes = Note.includes(:close_payment_histories, :invoice_inquiry, :invoice_details).where(currency_code: currency)
      invoices += debit_notes + notes
    end
    invoices.map{|inv| inv.grand_total if inv.is_payment_open? && inv.is_uncanceled?}.sum(&:to_f).round(2)
  end

  def self.invoice_not_create(currency)
    # shipping_instructions = ShippingInstruction.includes(:cost_revenue, :payment_references, bill_of_lading_invoices: [:bill_of_lading_items], bill_of_lading: [ invoices: [ :invoice_details ], debit_notes: [ :invoice_details ], notes: [ :invoice_details ] ]).where(is_shadow: false, is_cancel: 0)
    shipping_instructions = ShippingInstruction.where(is_shadow: false, is_cancel: 0)
    
    ibl_refs = []
    req_nos = []
    amount_estimate = 0
    shipping_instructions.each do |si|
      bl = si.bill_of_lading
      if !bl.blank? && !si.is_cr_completed?
        total_invoice_fr_payment_inquiry = 0
        unless bl.invoices.any? || bl.debit_notes.any? || bl.notes.any?
          bl.payments.uniq.each do |ref|
            if ref.is_uncanceled?
              if ref.currency == currency
                total_invoice_fr_payment_inquiry += ref.payment_references.map{|p| p.amount_invoice if p.ibl_ref == si.ibl_ref}.sum(&:to_f).round(2)
                # ref.payment_references.each do |p|
                #   total_invoice_fr_payment_inquiry += p.amount_invoice.to_f if p.ibl_ref == si.ibl_ref
                # end
                # total_invoice_fr_payment_inquiry += p.amount_invoice.to_f
                req_nos.push "#{ref.payment_no} #{total_invoice_fr_payment_inquiry}"
              end
            end
          end
        end
        ibl_refs.push "#{si.ibl_ref}\t#{total_invoice_fr_payment_inquiry}"
        amount_estimate += total_invoice_fr_payment_inquiry.round(2)
      end
    end
    # puts ibl_refs
    # puts req_nos
    amount_estimate.round(2)
  end

  def self.payment_not_create(currency)
    # shipping_instructions = ShippingInstruction.includes(:cost_revenue, bill_of_lading_invoices: [:bill_of_lading_items], bill_of_lading: [ invoices: [ :invoice_details ] ]).where(is_shadow: false, is_cancel: 0)
    shipping_instructions = ShippingInstruction.where(is_shadow: false, is_cancel: 0)
    
    ibl_refs = []
    amount_estimate = 0
    shipping_instructions.each do |si|
      bl = si.bill_of_lading
      if !bl.blank? && !si.is_cr_completed?
        total_invoice = 0
        unless bl.payments.uniq.any?
          bl.invoices.each do |inv|
            if inv.is_uncanceled?
              if inv.currency_code == currency
                total_invoice += inv.grand_total.to_f.round(2)
              end
            end
          end
          bl.debit_notes.each do |inv|
            if inv.is_uncanceled?
              if inv.currency_code == currency
                total_invoice += inv.grand_total.to_f.round(2)
              end
            end
          end
          bl.notes.each do |inv|
            if inv.is_uncanceled?
              if inv.currency_code == currency
                total_invoice -= inv.grand_total.to_f.round(2)
              end
            end
          end

          ibl_refs.push "#{si.ibl_ref}\t#{total_invoice}"
          amount_estimate += total_invoice.round(2)
        end
      end
    end
    # puts ibl_refs
    amount_estimate.round(2) * -1
  end

  def self.estimate_add_invoice
    # shipping_instructions = ShippingInstruction.includes(:cost_revenue, bill_of_lading_invoices: [:bill_of_lading_items], bill_of_lading: [ invoices: [ :invoice_details ] ]).where(is_shadow: false, is_cancel: 0)
    shipping_instructions = ShippingInstruction.where(is_shadow: false, is_cancel: 0)
    
    ibl_refs = []
    amount_estimate = 0
    shipping_instructions.each do |si|
      bl = si.bill_of_lading
      if !bl.blank? && !si.is_cr_completed?
        total_invoice_fr_payment_plan = si.total_payment_invoices.to_f.round(2)
        total_invoice_fr_payment_inquiry = 0
        total_invoice_fr_calculate = si.total_bill_of_lading_invoices.to_f
        total_invoice = 0

        if bl.payments.uniq.any? && (bl.invoices.any? || bl.debit_notes.any? || bl.notes.any?)
          rate1 = si.payment_invoices.first.try(:rate).to_f.round(2)
          rate1 = (rate1 == 0) ? 1 : rate1

          # if bl.payments.uniq.any?
            bl.payments.uniq.each do |ref|
              if ref.is_uncanceled?
                if ref.currency == "IDR"
                  total_invoice_fr_payment_inquiry += ref.payment_references.map{|p| p.amount_invoice if p.ibl_ref == si.ibl_ref}.sum(&:to_f).round(2)
                elsif ref.currency == "USD"
                  total_invoice_fr_payment_inquiry += (ref.payment_references.map{|p| p.amount_invoice if p.ibl_ref == si.ibl_ref}.sum(&:to_f) * rate1).round(2)
                end
              end
            end
          # end


          rate2 = si.bill_of_lading_invoices.first.try(:rate).to_f.round(2)
          rate2 = (rate2 == 0) ? 1 : rate2

          # if bl.invoices.any? || bl.debit_notes.any? || bl.notes.any?
            bl.invoices.each do |inv|
              if inv.is_uncanceled?
                if inv.currency_code == "IDR"
                  total_invoice += inv.grand_total.to_f.round(2)
                elsif inv.currency_code == "USD"
                  total_invoice += (inv.grand_total.to_f * rate2).round(2)
                end
              end
            end
            bl.debit_notes.each do |inv|
              if inv.is_uncanceled?
                if inv.currency_code == "IDR"
                  total_invoice += inv.grand_total.to_f.round(2)
                elsif inv.currency_code == "USD"
                  total_invoice += (inv.grand_total.to_f * rate2).round(2)
                end
              end
            end
            bl.notes.each do |inv|
              if inv.is_uncanceled?
                if inv.currency_code == "IDR"
                  total_invoice -= inv.grand_total.to_f.round(2)
                elsif inv.currency_code == "USD"
                  total_invoice -= (inv.grand_total.to_f * rate2).round(2)
                end
              end
            end
          # end
          
          ibl_refs.push "#{si.ibl_ref}\t#{total_invoice}\t#{total_invoice_fr_calculate}\t#{total_invoice_fr_payment_inquiry}\t#{total_invoice_fr_payment_plan}" unless (total_invoice_fr_calculate - total_invoice) == 0
          amount_estimate += (total_invoice_fr_calculate - total_invoice).round(2) unless (total_invoice_fr_calculate - total_invoice) == 0
        end
      end
    end
    # puts ibl_refs
    amount_estimate.round(2)
  end

  def self.estimate_add_payment
    # shipping_instructions = ShippingInstruction.includes(:cost_revenue, bill_of_lading_invoices: [:bill_of_lading_items], bill_of_lading: [ invoices: [ :invoice_details ] ]).where(is_shadow: false, is_cancel: 0)
    shipping_instructions = ShippingInstruction.where(is_shadow: false, is_cancel: 0)
    
    ibl_refs = []
    amount_estimate = 0
    shipping_instructions.each do |si|
      bl = si.bill_of_lading
      if !bl.blank? && !si.is_cr_completed?
        total_invoice_fr_payment_plan = si.total_payment_invoices.to_f.round(2)
        total_invoice_fr_payment_inquiry = 0
        total_invoice_fr_calculate = si.total_bill_of_lading_invoices.to_f
        total_invoice = 0

        if bl.payments.uniq.any? && (bl.invoices.any? || bl.debit_notes.any? || bl.notes.any?)
          rate1 = si.payment_invoices.first.try(:rate).to_f.round(2)
          rate1 = (rate1 == 0) ? 1 : rate1

          # if bl.payments.uniq.any?
            bl.payments.uniq.each do |ref|
              if ref.is_uncanceled?
                if ref.currency == "IDR"
                  total_invoice_fr_payment_inquiry += ref.payment_references.map{|p| p.amount_invoice if p.ibl_ref == si.ibl_ref}.sum(&:to_f).round(2)
                elsif ref.currency == "USD"
                  total_invoice_fr_payment_inquiry += (ref.payment_references.map{|p| p.amount_invoice if p.ibl_ref == si.ibl_ref}.sum(&:to_f) * rate1).round(2)
                end
              end
            end
          # end


          rate2 = si.bill_of_lading_invoices.first.try(:rate).to_f.round(2)
          rate2 = (rate2 == 0) ? 1 : rate2

          # if bl.invoices.any? || bl.debit_notes.any? || bl.notes.any?
            bl.invoices.each do |inv|
              if inv.is_uncanceled?
                if inv.currency_code == "IDR"
                  total_invoice += inv.grand_total.to_f.round(2)
                elsif inv.currency_code == "USD"
                  total_invoice += (inv.grand_total.to_f * rate2).round(2)
                end
              end
            end
            bl.debit_notes.each do |inv|
              if inv.is_uncanceled?
                if inv.currency_code == "IDR"
                  total_invoice += inv.grand_total.to_f.round(2)
                elsif inv.currency_code == "USD"
                  total_invoice += (inv.grand_total.to_f * rate2).round(2)
                end
              end
            end
            bl.notes.each do |inv|
              if inv.is_uncanceled?
                if inv.currency_code == "IDR"
                  total_invoice -= inv.grand_total.to_f.round(2)
                elsif inv.currency_code == "USD"
                  total_invoice -= (inv.grand_total.to_f * rate2).round(2)
                end
              end
            end
          # end
      
          ibl_refs.push "#{si.ibl_ref}\t#{total_invoice}\t#{total_invoice_fr_calculate}\t#{total_invoice_fr_payment_inquiry}\t#{total_invoice_fr_payment_plan}" unless (total_invoice_fr_payment_plan - total_invoice_fr_payment_inquiry) == 0
          amount_estimate += (total_invoice_fr_payment_plan - total_invoice_fr_payment_inquiry).round(2) unless (total_invoice_fr_payment_plan - total_invoice_fr_payment_inquiry) == 0
        end
      end
    end
    # puts ibl_refs
    (amount_estimate * -1).round(2)
  end

  def self.deposit_at_liner(currency)
    total = 0
    payment_references = PaymentReference.includes(:payment, :shipping_instruction).where.not(amount_invoice: nil, amount_overpaid: nil).where("payment_references.amount_overpaid > 0").references(:payment).order(ibl_ref: :desc)
    payment_references = payment_references.where("payments.is_cancel = ? AND payments.payment_type = ?", 0, currency)
    payment_references.group_by(&:ibl_ref).each do |ibl_ref, references|
      references.group_by{|a| a.carrier_id}.each do |carrier_id, refs2|
        refs2.group_by{|a| a.currency}.each do |currency, refs3|
          total += Payment.idr_balance(refs3.first.carrier_id, refs3.first.ibl_ref) if currency == "IDR"
          total += Payment.usd_balance(refs3.first.carrier_id, refs3.first.ibl_ref) if currency == "USD"
        end
      end      
    end
    total
  end

  def self.deposit_from_shipper(currency)
    total = 0
    Constant.years_range.each do |year|
      invoices = InvoiceServices.find_with_deposit({year: year})
      invoices = invoices.to_a.delete_if{|x| x.payment_date.blank? || x.invoice_inquiry.blank? || x.shipping_instruction.is_canceled?}
      invoices.each do |invoice|
        if invoice.invoice_inquiry.currency_2 == currency
          invoice.invoice_references.each do |ref|
            total += ref.deposit.to_f
          end
          InvoiceDeposit.includes(:close_payment).where("invoice_deposits.invoice_deposit = ?", invoice.invoice_no).where("close_payments.is_shadow = ?", false).references(:close_payment).each do |deposit|
            total -= deposit.try(:amount).to_f
          end
          total -= InvoiceCloseDeposit.where(invoice_no: invoice.invoice_no).first.try(:amount).to_f
        end
      end
    end
    total * -1
  end

  def self.shortpaid_from_shipper(currency)
    total = 0
    Constant.years_range.each do |year|
      invoices = InvoiceServices.find_with_short_paid({year: year})
      invoices = invoices.to_a.delete_if{|x| x.payment_date.blank? || x.invoice_inquiry.blank? || x.shipping_instruction.is_canceled?}
      invoices.each do |invoice|
        invoice.invoice_references.each do |ref|
          total += ref.short_paid.to_f if ref.short_paid_status == 0 && ref.currency_2 == currency
        end
      end
    end
    total * -1
  end

  def self.deposit_at_carrier(currency)
    deposit = 0
    deposit += PaymentReference.includes(:payment).where.not(amount_invoice: nil).map{|p| p.payment.currency == currency ? p.amount_deposit : 0}.sum(&:to_f).round(2)
    deposit -= PaymentDeposit.includes(:payment).map{|p| p.payment.currency == currency ? p.amount : 0}.sum(&:to_f).round(2)
    deposit.round(2)
  end
  
  def filename
    tmp = "Balance"
    tmp += " #{Date.today.strftime('%d-%b-%Y')}"
    tmp.upcase
  end

  def title
    tmp = "Balance"
    tmp += " #{Date.today.strftime('%d-%b-%Y')}"
    tmp.upcase
  end

  def populate_data
  end

  def template
    "balance_report"
  end
end
