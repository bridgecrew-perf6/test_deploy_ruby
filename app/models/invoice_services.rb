class InvoiceServices
  def self.report_invoices(params)
    @invoices = Invoice.none
    @debit_notes = DebitNote.none
    @notes = Note.none

    letter = params[:invoice_type].to_s

    if letter.empty?
      @invoices = Invoice.all
      @debit_notes = DebitNote.all
      @notes = Note.all
    else
      if letter == "Invoice"
        @invoices = Invoice.where(head_letter: params[:invoice_type])
      elsif letter == "Debit Note" || letter == "Reimbursement Cost"
        @debit_notes = DebitNote.where(head_letter: params[:invoice_type])
      elsif letter == "Credit Note"
        @notes = Note.where(head_letter: params[:invoice_type])
      end
    end

    begin
      case params[:filter_invoices_by]
      when "yearly"
        year = Constant.years_range.include?(params[:filter_invoices_yearly].to_i) ? params[:filter_invoices_yearly] : Date.today.year
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        @debit_notes = @debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        @notes = @notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      when "monthly"
        date = Date.parse(params[:filter_invoices_monthly])
        @invoices = @invoices.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @debit_notes = @debit_notes.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @notes = @notes.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      end
    end 

    (@invoices + @debit_notes + @notes)
  end

  def self.outstanding_invoices(params)
    @invoices = Invoice.where(status_payment: 0, is_cancel: 0).where("invoices.due_date < ?", Date.today)
    @debit_notes = DebitNote.where(status_payment: 0, is_cancel: 0).where("debit_notes.due_date < ?", Date.today)
    @notes = Note.where(status_payment: 0, is_cancel: 0).where("notes.due_date < ?", Date.today)

    unless params[:year].to_s.empty?
      filter_year = "IBL" + params[:year][2..3]
      @invoices = @invoices.where("invoices.ibl_no LIKE ?", "#{filter_year}%")
      @debit_notes = @debit_notes.where("debit_notes.ibl_no LIKE ?", "#{filter_year}%")
      @notes = @notes.where("notes.ibl_no LIKE ?", "#{filter_year}%")
    end

    begin
      case params[:filter_outstanding_by]
      when "yearly"
        year = Constant.years_range.include?(params[:filter_outstanding_yearly].to_i) ? params[:filter_outstanding_yearly] : Date.today.year
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        @debit_notes = @debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        @notes = @notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      when "monthly"
        date = Date.parse(params[:filter_outstanding_monthly])
        @invoices = @invoices.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @debit_notes = @debit_notes.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @notes = @notes.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      end
    end 

    (@invoices + @debit_notes + @notes)
  end

  def self.unpaid_invoices(params)
    @invoices = Invoice.all
    @debit_notes = DebitNote.all
    @notes = Note.all

    # if params[:year].to_i > 0
    #   @invoices = @invoices.where("YEAR(invoice_date) = ?", params[:year].to_i)
    #   @debit_notes = @debit_notes.where("YEAR(dbn_date) = ?", params[:year].to_i)
    #   @notes = @notes.where("YEAR(note_date) = ?", params[:year].to_i)
    # end

    begin
      case params[:filter_unpaid_by]
      when "yearly"
        year = Constant.years_range.include?(params[:filter_unpaid_yearly].to_i) ? params[:filter_unpaid_yearly] : Date.today.year
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        @debit_notes = @debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        @notes = @notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      when "monthly"
        date = Date.parse(params[:filter_unpaid_monthly])
        @invoices = @invoices.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @debit_notes = @debit_notes.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @notes = @notes.recent_with_vessels.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      end
    end 

    @invoices = @invoices.where(status_payment: 0, is_cancel: 0).order(:invoice_date)
    @debit_notes = @debit_notes.where(status_payment: 0, is_cancel: 0).order(:dbn_date)
    @notes = @notes.where(status_payment: 0, is_cancel: 0).order(:note_date)

    (@invoices + @debit_notes + @notes).sort! { |a, b|
      (a.try(:invoice_date) || a.try(:dbn_date) || a.try(:note_date)) <=>
        (b.try(:invoice_date) || b.try(:dbn_date) || b.try(:note_date))
    }
  end

  # def self.find_with(params)
  #   require 'will_paginate/array'

  #   @invoices = Invoice.includes(invoice_details: [ :invoice ], shipping_instruction: [ :vessels ]).recent
  #   @debit_notes = DebitNote.includes(invoice_details: [ :debit_note ], shipping_instruction: [ :vessels ]).recent
  #   @notes = Note.includes(invoice_details: [ :note ], shipping_instruction: [ :vessels ]).recent

  #   # unless params[:query].to_s.empty?
  #   #   @invoices = @invoices.search(params[:query])
  #   #   @debit_notes = @debit_notes.search(params[:query])
  #   #   @notes = @notes.search(params[:query])
  #   # end

  #   # if params[:cancel].to_i == 1
  #   #   @invoices = @invoices.where(is_cancel: 1)
  #   #   @debit_notes = @debit_notes.where(is_cancel: 1)
  #   #   @notes = @notes.where(is_cancel: 1)
  #   # end

  #   # unless params[:status].to_s.empty?
  #   #   @invoices = @invoices.where(status: params[:status])
  #   #   @debit_notes = @debit_notes.where(status: params[:status])
  #   #   @notes = @notes.where(status: params[:status])
  #   # end

  #   # unless params[:bid].to_s.empty?
  #   #   @invoices = @invoices.where(bill_of_lading_id: params[:bid])
  #   #   @debit_notes = @debit_notes.where(bill_of_lading_id: params[:bid])
  #   #   @notes = @notes.where(bill_of_lading_id: params[:bid])
  #   # end

  #   # unless params[:sort].to_s.empty?
  #   #   @invoices = @invoices.where(head_letter: params[:sort])
  #   #   @debit_notes = @debit_notes.where(head_letter: params[:sort])
  #   #   @notes = @notes.where(head_letter: params[:sort])
  #   # end

  #   year = params[:year].presence || Date.today.year
  #   if year.to_i > 0
  #     @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
  #     @debit_notes = @debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
  #     @notes = @notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
  #   end

  #   # unless params[:tax_issued].to_s.blank?
  #   #   tax_issued = Date.parse(params[:tax_issued])
  #   #   @invoices = @invoices.where("tax_issued >= ? and tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
  #   #   @debit_notes = @debit_notes.where("tax_issued >= ? and tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
  #   #   @notes = @notes.where("tax_issued >= ? and tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
  #   # end
    
  #   (@invoices + @debit_notes + @notes) #.paginate(page: params[:page])
  #   # @invoices
  # end

  def self.find_with(params)
    if Rails.env.development?
      @invoices = Invoice.includes(invoice_details: [ :invoice ], shipping_instruction: [ :vessels ]).recent
      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
      end
      
      @invoices.first(5)
    else

      @invoices = Invoice.includes(invoice_details: [ :invoice ], shipping_instruction: [ :vessels ]).recent
      @debit_notes = DebitNote.includes(invoice_details: [ :debit_note ], shipping_instruction: [ :vessels ]).recent
      @notes = Note.includes(invoice_details: [ :note ], shipping_instruction: [ :vessels ]).recent

      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        @debit_notes = @debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        @notes = @notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      end

      (@invoices + @debit_notes + @notes)
      # @invoices.first(5)
      # @debit_notes.first(5)
      # @notes.first(5)
    end
  end

  def self.find_with_vessels(params)
    require 'will_paginate/array'

    @invoices = Invoice.recent_with_vessels
    @debit_notes = DebitNote.recent_with_vessels
    @notes = Note.recent_with_vessels

    if params[:bid].presence && params[:bid].to_i > 0
      @invoices = @invoices.where(bill_of_lading_id: params[:bid])
      @debit_notes = @debit_notes.where(bill_of_lading_id: params[:bid])
      @notes = @notes.where(bill_of_lading_id: params[:bid])
    end

    if params.has_key?(:shipper_id) && !params[:shipper_id].blank?
      @invoices = @invoices.where("shipping_instructions.shipper_id = ?", params[:shipper_id])
      @debit_notes = @debit_notes.where("shipping_instructions.shipper_id = ?", params[:shipper_id])
      @notes = @notes.where("shipping_instructions.shipper_id = ?", params[:shipper_id])
    end

    if params.has_key?(:date_filter) && !params[:date_filter].to_s.empty?
      begin
        date = Date.parse(params[:date_filter])
        @invoices = @invoices.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @debit_notes = @debit_notes.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
        @notes = @notes.where("VS.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
      rescue
        # ignored
      end
    elsif params.has_key?(:filter_year) && !params[:filter_year].to_s.empty?
      @invoices = @invoices.where("YEAR(VS.etd_date) = ?", params[:filter_year].to_i)
      @debit_notes = @debit_notes.where("YEAR(VS.etd_date) = ?", params[:filter_year].to_i)
      @notes = @notes.where("YEAR(VS.etd_date) = ?", params[:filter_year].to_i)
    end

    if params[:status].to_i != -1 && params[:status].to_i != 2
      @invoices = @invoices.where(status_payment: params[:status])
      @debit_notes = @debit_notes.where(status_payment: params[:status])
      @notes = @notes.where(status_payment: params[:status])
    end

    @invoices = @invoices.where(is_cancel: 0)
    @debit_notes = @debit_notes.where(is_cancel: 0)
    @notes = @notes.where(is_cancel: 0)

    (@invoices + @debit_notes + @notes)
  end

  def self.find_with_payments(params)
    if Rails.env.development?
      @invoices = Invoice.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).recent
      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
      end
      # invoices = invoices.where(customer: params[:customer])
      @invoices = @invoices.where("customer LIKE ?", "%AN LEADER SHIPPING CO LTD%")
      # @invoices = @invoices.where("customer LIKE ?", "%PT. ASIANAGRO AGUNGJAYA%")
      # @invoices = @invoices.where("customer LIKE ?", "%PT. ASIETEX SINAR INDOPRATAMA%")
      # @invoices = @invoices.where("customer LIKE ?", "%PT. HAGIHARA WESTJAVA INDUSTRIES%")
      # @invoices = @invoices.where("customer LIKE ?", "%PT. INDESSO AROMA%")
      # @invoices = @invoices.where("customer LIKE ?", "%PT. INTRADITA PROSIMPEX%")
      @invoices.first(100)
    else
      @invoices = Invoice.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).recent
      @debit_notes = DebitNote.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).recent
      @notes = Note.includes(:close_payment_histories, :invoice_inquiry, :invoice_references, :invoice_details, shipping_instruction: [ :vessels ]).recent

      # unless params[:query].to_s.empty?
      #   @invoices = @invoices.search(params[:query])
      #   @debit_notes = @debit_notes.search(params[:query])
      #   @notes = @notes.search(params[:query])
      # end

      # if params[:cancel].to_i == 1
      #   @invoices = @invoices.where(is_cancel: 1)
      #   @debit_notes = @debit_notes.where(is_cancel: 1)
      #   @notes = @notes.where(is_cancel: 1)
      # end

      # unless params[:status].to_s.empty?
      #   @invoices = @invoices.where(status: params[:status])
      #   @debit_notes = @debit_notes.where(status: params[:status])
      #   @notes = @notes.where(status: params[:status])
      # end

      # unless params[:bid].to_s.empty?
      #   @invoices = @invoices.where(bill_of_lading_id: params[:bid])
      #   @debit_notes = @debit_notes.where(bill_of_lading_id: params[:bid])
      #   @notes = @notes.where(bill_of_lading_id: params[:bid])
      # end

      # unless params[:sort].to_s.empty?
      #   @invoices = @invoices.where(head_letter: params[:sort])
      #   @debit_notes = @debit_notes.where(head_letter: params[:sort])
      #   @notes = @notes.where(head_letter: params[:sort])
      # end

      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        @invoices = @invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        @debit_notes = @debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        @notes = @notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      end

      # unless params[:tax_issued].to_s.blank?
      #   tax_issued = Date.parse(params[:tax_issued])
      #   @invoices = @invoices.where("tax_issued >= ? and tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
      #   @debit_notes = @debit_notes.where("tax_issued >= ? and tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
      #   @notes = @notes.where("tax_issued >= ? and tax_issued <= ? ", tax_issued.beginning_of_month, tax_issued.end_of_month)
      # end
      
      (@invoices + @debit_notes + @notes) #.paginate(page: params[:page])
    end
  end

  def self.get_shipping_instructions(invoices, params)
    shipping_instructions = ShippingInstruction.all

    begin
      if params[:status].to_i == 2
        date = Date.parse(params[:date_filter])
        shipping_instructions = shipping_instructions.joins("LEFT OUTER JOIN vessels ON (vessels.id = (SELECT NV.id FROM vessels NV WHERE NV.shipping_instruction_id = shipping_instructions.id LIMIT 1))")

        if invoices.any?
          available_si = invoices.map { |e| e.bill_of_lading.shipping_instruction.id }
          shipping_instructions = shipping_instructions.where.not(id: available_si)
        end

        if params.has_key?(:shipper_id) && !params[:shipper_id].blank?
          shipping_instructions = shipping_instructions.where(shipper_id: params[:shipper_id])
        end

        shipping_instructions = shipping_instructions.where("(vessels.etd_date BETWEEN ? AND ?)", date.at_beginning_of_month, date.end_of_month)
        .where(is_shadow: 0, is_cancel: 0)
      else
        raise
      end
    rescue => e
      shipping_instructions = ShippingInstruction.none
    end

    shipping_instructions
  end

  def self.initialize_new_close_payments(params)
    # invoice = Invoice.first
    invoice = BulkClosePayment.first

    params[:invoice_no].delete_if{|e| e.squish.length == 0}.each do |invoice_no|
      inv = Invoice.find_by(no_invoice: invoice_no, status_payment: 0, is_cancel: 0) if invoice_no.include? "INV"
      inv = DebitNote.find_by(no_dbn: invoice_no, status_payment: 0, is_cancel: 0) if invoice_no.include? "DBN"
      inv = Note.find_by(no_note: invoice_no, status_payment: 0, is_cancel: 0) if invoice_no.include? "CRN" 

      si = inv.shipping_instruction
      # if inv.is_payment_open? && inv.is_uncanceled? && !si.is_cr_completed? && inv.close_payment_histories.blank?
      if inv.is_close_payment?
        invoice.close_payments.build(ibl_ref: inv.ibl_ref, customer: inv.customer, shipper: inv.shipper, invoice_no: inv.invoice_no, currency: inv.currency_code, amount: inv.grand_total)
      end
    end
    # 3.times{ invoice.additional_payments.build }
    # 3.times{ invoice.deposit_payments.build }
    invoice
  end

  def self.initialize_edit_close_payments(params)
    # invoice = Invoice.first
    invoice = BulkClosePayment.first

    close_payments = ClosePayment.where(close_ref: params[:close_ref].to_i, is_shadow: false)
    close_payments.each do |inv|
      invoice.close_payments.build(ibl_ref: inv.ibl_ref, customer: inv.customer, shipper: inv.shipper, invoice_no: inv.invoice_no, currency: inv.currency, amount: inv.amount)
      inv.invoice_payments.each do |p|
        invoice.additional_payments.build(invoice_no: p.invoice_no, bank_charge: p.bank_charge, rounding: p.rounding, short_paid: p.short_paid, deposit: p.deposit, pph_23: p.pph_23, other: p.other, note: p.note)
      end
      inv.invoice_deposits.each do |p|
        invoice.deposit_payments.build(invoice_deposit: p.invoice_deposit, ibl_deposit: p.ibl_deposit, amount: p.amount, invoice_no: p.invoice_no)
      end
    end
    # (3-invoice.additional_payments.length).times{ invoice.additional_payments.build }
    # (3-invoice.deposit_payments.length).times{ invoice.deposit_payments.build }
    invoice.close_payment_rate = close_payments.last.rate
    invoice.close_payment_date = close_payments.last.payment_date
    invoice.close_payment_status = close_payments.last.status
    invoice.close_payment_close_ref = close_payments.last.close_ref
    invoice
  end

  def self.get_ibl_ref_with_invoice_no(params)
    # if Rails.env.development?
    #   invoices = Invoice.includes(:shipping_instruction).recent

    #   # invoices = invoices.where(status_payment: 0, is_cancel: 0)
    #   invoices = invoices.where(is_cancel: 0)
    #   invoices = invoices.where(customer: params[:customer]) unless params[:customer].blank?
      
    #   year = params[:year].presence || Date.today.year
    #   if year.to_i > 0
    #     invoices = invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
    #   end

    #   # invoices = [] + invoices
    # else
      invoices = Invoice.includes(:shipping_instruction).recent
      debit_notes = DebitNote.includes(:shipping_instruction).recent
      notes = Note.includes(:shipping_instruction).recent

      # invoices = invoices.where(status_payment: 0, is_cancel: 0)
      # debit_notes = debit_notes.where(status_payment: 0, is_cancel: 0)
      # notes = notes.where(status_payment: 0, is_cancel: 0)
      invoices = invoices.where(is_cancel: 0)
      debit_notes = debit_notes.where(is_cancel: 0)
      notes = notes.where(is_cancel: 0)

      unless params[:customer].blank?
        # invoices = invoices.where(customer: params[:customer])
        # debit_notes = debit_notes.where(customer: params[:customer])
        # notes = notes.where(customer: params[:customer])

        invoices = invoices.where("customer LIKE ?", "%#{params[:customer].first.squish}%")
        debit_notes = debit_notes.where("customer LIKE ?", "%#{params[:customer].first.squish}%")
        notes = notes.where("customer LIKE ?", "%#{params[:customer].first.squish}%")
      end
      
      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        invoices = invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        debit_notes = debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        notes = notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      end
      
      invoices = invoices + debit_notes + notes
    # end

    data = []
    invoices.sort_by{|a| a.ibl_ref}.each do |inv|
      si = inv.shipping_instruction
      # if inv.is_payment_open? && inv.is_uncanceled? && !si.is_cr_completed? && inv.close_payment_histories.blank?
      if inv.is_close_payment?
        data.push(
          {
            ibl_ref: inv.ibl_ref, 
            customer: inv.customer, 
            shipper: inv.shipper, 
            invoice_no: inv.invoice_no, 
            currency: inv.currency_code, 
            amount: inv.grand_total
          }
        )
      end
    end
    get_ibl_ref_with_invoice_no = begin
      if data.nil? || data.blank?
        {success: false, message: "No Invoice Open"}
      else
        {success: true, results: data}
      end
    end
    get_ibl_ref_with_invoice_no
  end

  def self.find_with_short_paid(params)
    if Rails.env.development?
      invoices = Invoice.includes(:invoice_references).references(:invoice_references).recent
      
      invoices = invoices.where(is_cancel: 0)
      
      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        invoices = invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
      end
      
      invoices = invoices.where.not("invoice_payments.short_paid IN ('0','') OR invoice_payments.short_paid IS NULL")
   
      invoices.first(5)
    else
      invoices = Invoice.includes(:invoice_references).references(:invoice_references).recent
      debit_notes = DebitNote.includes(:invoice_references).references(:invoice_references).recent
      notes = Note.includes(:invoice_references).references(:invoice_references).recent
      
      invoices = invoices.where(is_cancel: 0)
      debit_notes = debit_notes.where(is_cancel: 0)
      notes = notes.where(is_cancel: 0)

      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        invoices = invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        debit_notes = debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        notes = notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      end
      
      invoices = invoices.where.not("invoice_payments.short_paid IN ('0','') OR invoice_payments.short_paid IS NULL")
      debit_notes = debit_notes.where.not("invoice_payments.short_paid IN ('0','') OR invoice_payments.short_paid IS NULL")
      notes = notes.where.not("invoice_payments.short_paid IN ('0','') OR invoice_payments.short_paid IS NULL")
      
      (invoices + debit_notes + notes) #.paginate(page: params[:page])
    end
  end

  def self.find_with_deposit(params)
    if Rails.env.development?
      invoices = Invoice.includes(:invoice_inquiry, :invoice_references).references(:invoice_references).recent
      
      invoices = invoices.where(is_cancel: 0)
      
      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        invoices = invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
      end
      
      invoices = invoices.where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL")
   
      invoices.first(5)
    else
      invoices = Invoice.includes(:invoice_inquiry, :invoice_references).references(:invoice_references).recent
      debit_notes = DebitNote.includes(:invoice_inquiry, :invoice_references).references(:invoice_references).recent
      notes = Note.includes(:invoice_inquiry, :invoice_references).references(:invoice_references).recent
      
      invoices = invoices.where(is_cancel: 0)
      debit_notes = debit_notes.where(is_cancel: 0)
      notes = notes.where(is_cancel: 0)

      year = params[:year].presence || Date.today.year
      if year.to_i > 0
        invoices = invoices.where("no_invoice LIKE ?", "IBLINV#{year.to_s[2..3]}%")
        debit_notes = debit_notes.where("no_dbn LIKE ?", "IBLDBN#{year.to_s[2..3]}%")
        notes = notes.where("no_note LIKE ?", "IBLCRN#{year.to_s[2..3]}%")
      end
      
      invoices = invoices.where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL")
      debit_notes = debit_notes.where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL")
      notes = notes.where.not("invoice_payments.deposit IN ('0','') OR invoice_payments.deposit IS NULL")
      
      (invoices + debit_notes + notes) #.paginate(page: params[:page])
    end
  end

  def self.find_with_invoice_no(invoice_no)
    inv = begin
      if invoice_no.include? "INV"
        Invoice.find_by(no_invoice: invoice_no)
      elsif invoice_no.include? "DBN"
        DebitNote.find_by(no_dbn: invoice_no)
      elsif invoice_no.include? "CRN"
        Note.find_by(no_note: invoice_no)
      end
    end
    inv
  end
end