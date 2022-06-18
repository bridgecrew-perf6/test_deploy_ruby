module ReportsHelper
  def report_list_si(row, format)
    if format == "pdf"
      Rails.cache.fetch(["report-list-si-pdf", row]) do
        body = []
        body = [  "",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{row.shipper_reference}</td>",
                  "<td>#{row.shipper_company_name}</td>",
                  "<td>#{row.volume}</td>",
                  "<td>#{row.final_destination}</td>",
                  "<td>#{si_date_format row.first_etd_date}</td>",
                  "<td>#{si_date_format row.si_date}</td>",
                  "<td>#{row.carrier}</td>",
                  "<td>#{row.consignee_company_name}</td>",
                  "<td>#{row.first_line_notify_party}</td>",
                  "<td>#{row.port_of_loading}</td>",
                  "<td>#{row.booking_no}</td>",
                  "<td>#{row.master_bl_no}</td>",
                  "<td>#{row.order_type_text}</td>",
                  "<td>#{row.handler_name}</td>" ]
        body
      end
    elsif format == "xls"
      Rails.cache.fetch(["report-list-si-xls", row]) do
        body = []
        body = [  "",
                  "#{row.ibl_ref_with_status}\t",
                  "#{row.shipper_reference}\t",
                  "#{row.shipper_company_name}\t",
                  "#{row.volume}\t",
                  "#{row.final_destination}\t",
                  "#{si_date_format row.first_etd_date}\t",
                  "#{si_date_format row.si_date}\t",
                  "#{row.carrier}\t",
                  "#{row.consignee_company_name}\t",
                  "#{row.first_line_notify_party}\t",
                  "#{row.port_of_loading}\t",
                  "#{row.booking_no}\t",
                  "#{row.master_bl_no}\t",
                  "#{row.order_type_text}\t",
                  "#{row.handler_name}\t" ]
        body
      end
    end
  end

  def report_list_bl(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-bl-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{reference.ibl_ref_with_status}</td>",
                  "<td>#{reference.master_bl_no}</td>",
                  "<td>#{reference.carrier}</td>",
                  "<td>#{reference.shipper_company_name}</td>",
                  "<td>#{reference.consignee_company_name}</td>",
                  "<td>#{reference.first_line_notify_party}</td>",
                  "<td>#{reference.final_destination}</td>",
                  "<td>#{reference.invoice_no.join('<br>')}</td>",
                  "<td>#{reference.volume}</td>",
                  "<td>#{reference.order_type_text}</td>",
                  "<td>#{reference.payment_no.join('<br>')}</td>",
                  "<td>#{reference.port_of_loading}</td>",
                  "<td>#{si_date_format reference.first_etd_date}</td>",
                  "<td>#{reference.delivery_doc_status}</td>" ]
        body
      end
    elsif format == "xls"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-bl-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{reference.ibl_ref_with_status}\t",
                  "#{reference.master_bl_no}\t",
                  "#{reference.carrier}\t",
                  "#{reference.shipper_company_name}\t",
                  "#{reference.consignee_company_name}\t",
                  "#{reference.first_line_notify_party}\t",
                  "#{reference.final_destination}\t",
                  "#{reference.invoice_no.join(', ')}\t",
                  "#{reference.volume}\t",
                  "#{reference.order_type_text}\t",
                  "#{reference.payment_no.join(', ')}\t",
                  "#{reference.port_of_loading}\t",
                  "#{si_date_format reference.first_etd_date}\t",
                  "#{reference.delivery_doc_status}\t" ]
        body
      end
    end
  end

  def report_list_st(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-st-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{reference.ibl_ref_with_status}</td>",
                  "<td>#{row.shipper_company_name}</td>",
                  "<td>#{row.consignee_company_name}</td>",
                  "<td>#{row.carrier}</td>",
                  "<td>#{row.feeder_vessel}</td>",
                  "<td>#{si_date_format row.feeder.try(:etd_date)}</td>",
                  "<td>#{row.port_of_loading}</td>",
                  "<td>#{row.final_destination}</td>",
                  "<td>#{si_date_format row.destination.try(:eta_date)}</td>",
                  "<td>#{row.shipper_reference}</td>",
                  "<td>#{row.booking_no}</td>",
                  "<td>#{row.master_bl_no}</td>",
                  "<td>#{transit_time_format(row.transit_time)}</td>",
                  "<td>#{reference.status_free_time}</td>",
                  "<td>#{simple_format reference.notes}</td>",
                  "<td>#{si_date_format(reference.fu_date.presence || row.feeder.try(:etd_date))}</td>" ]
        body
      end
    elsif format == "xls"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-st-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{reference.ibl_ref_with_status}\t",
                  "#{row.shipper_company_name}\t",
                  "#{row.consignee_company_name}\t",
                  "#{row.carrier}\t",
                  "#{row.feeder_vessel}\t",
                  "#{si_date_format row.feeder.try(:etd_date)}\t",
                  "#{row.port_of_loading}\t",
                  "#{row.final_destination}\t",
                  "#{si_date_format row.destination.try(:eta_date)}\t",
                  "#{row.shipper_reference}\t",
                  "#{row.booking_no}\t",
                  "#{row.master_bl_no}\t",
                  "#{transit_time_format(row.transit_time)}\t",
                  "#{reference.status_free_time}\t",
                  "#{reference.notes.squish unless reference.notes.blank?}\t",
                  "#{si_date_format(reference.fu_date.presence || row.feeder.try(:etd_date))}\t" ]
        body
      end
    end
  end

  def report_list_invoice(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-invoice-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{reference.invoice_no_with_status}</td>",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{reference.currency_code}</td>",
                  "<td style=\"text-align:right\">#{money_format(reference.grand_total)}</td>",
                  "<td>#{reference.customer_ori}</td>",
                  "<td>#{reference.to_shipper}</td>",
                  "<td>#{reference.port_of_loading}</td>",
                  "<td>#{reference.status_info}</td>",
                  "<td>#{reference.vat_10_no}</td>",
                  "<td style=\"text-align:right\">#{money_format(reference.vat_10_tax) unless reference.is_canceled?}</td>",
                  "<td>#{reference.vat_1_no}</td>",
                  "<td style=\"text-align:right\">#{money_format(reference.vat_1_tax) unless reference.is_canceled?}</td>",
                  "<td>#{reference.pph_23_no}</td>",
                  "<td style=\"text-align:right\">#{money_format(reference.pph_23_tax) unless reference.is_canceled?}</td>",
                  "<td>#{reference.status_tax.humanize}</td>",
                  "<td>#{monthly_format reference.tax_issued}</td>",
                  "<td>#{monthly_format reference.paid_month}</td>",
                  "<td>#{si_date_format reference.invoice_date}</td>" ]
        body
      end
    elsif format == "xls"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-invoice-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{reference.invoice_no_with_status}\t",
                  "#{row.ibl_ref_with_status}\t",
                  "#{reference.currency_code}\t",
                  "#{money_format(reference.grand_total)}\t",
                  "#{reference.customer_ori}\t",
                  "#{reference.to_shipper}\t",
                  "#{reference.port_of_loading}\t",
                  "#{reference.status_info}\t",
                  "#{reference.vat_10_no}\t",
                  "#{money_format(reference.vat_10_tax) unless reference.is_canceled?}\t",
                  "#{reference.vat_1_no}\t",
                  "#{money_format(reference.vat_1_tax) unless reference.is_canceled?}\t",
                  "#{reference.pph_23_no}\t",
                  "#{money_format(reference.pph_23_tax) unless reference.is_canceled?}\t",
                  "#{reference.status_tax.humanize}\t",
                  "#{monthly_format reference.tax_issued}\t",
                  "#{monthly_format reference.paid_month}\t",
                  "#{si_date_format reference.invoice_date}\t", ]
        body
      end
    end
  end

  def report_list_payment_plan(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-payment-plan-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{row.booking_no}</td>",
                  "<td>#{row.master_bl_no}</td>",
                  "<td>#{row.volume}</td>",
                  "<td>#{reference.carrier}</td>",
                  "<td>#{row.shipper_company_name}</td>",
                  "<td>#{row.port_of_loading}</td>",
                  "<td>#{row.final_destination}</td>",
                  "<td style=\"text-align:right\">#{money_format reference.total_invoice}</td>",
                  "<td>#{si_date_format reference.payment_date}</td>",
                  "<td>#{si_date_format row.first_etd_date}</td>",
                  "<td>#{reference.paid_status}</td>",
                  "<td>#{row.bl_status}</td>" ]
        body
      end
    elsif format == "xls"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-payment-plan-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{row.ibl_ref_with_status}\t",
                  "#{row.booking_no}\t",
                  "#{row.master_bl_no}\t",
                  "#{row.volume}\t",
                  "#{reference.carrier}\t",
                  "#{row.shipper_company_name}\t",
                  "#{row.port_of_loading}\t",
                  "#{row.final_destination}\t",
                  "#{money_format reference.total_invoice}\t",
                  "#{si_date_format reference.payment_date}\t",
                  "#{si_date_format row.first_etd_date}\t",
                  "#{reference.paid_status}\t",
                  "#{row.bl_status}\t" ]
        body
      end
    end
  end

  def report_list_payment_inquiry(reference, format)
    if format == "pdf"
      row = reference.payment
      Rails.cache.fetch(["report-list-payment-inquiry-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{row.payment_no_with_status}</td>",
                  "<td>#{reference.ibl_ref_with_status}</td>",
                  "<td>#{reference.master_bl_no}</td>",
                  "<td>#{reference.shipper_company_name}</td>",
                  "<td>#{reference.port_of_loading}</td>",
                  "<td>#{reference.final_destination}</td>",
                  "<td>#{reference.volume}</td>",
                  "<td>#{row.carrier_name}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(reference.amount_payment.blank? ? reference.amount : reference.amount_payment, row.currency)}</td>",
                  "<td>#{simple_format row.notes}</td>",
                  "<td>#{si_date_format reference.first_etd_date}</td>",
                  "<td>#{row.payment_date}</td>",
                  "<td>#{row.status_info}</td>",
                  "<td>#{money_with_currency_format(reference.amount_misc, reference.currency) }</td>",
                  "<td>#{money_with_currency_format(reference.amount_invoice, reference.currency)}</td>"
                ]
        body
      end
    elsif format == "xls"
      row = reference.payment
      Rails.cache.fetch(["report-list-payment-inquiry-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{row.payment_no_with_status}\t",
                  "#{reference.ibl_ref_with_status}\t",
                  "#{reference.master_bl_no}\t",
                  "#{reference.shipper_company_name}\t",
                  "#{reference.port_of_loading}\t",
                  "#{reference.final_destination}\t",
                  "#{reference.volume}\t",
                  "#{row.carrier_name}\t",
                  "#{money_with_currency_format(reference.amount_payment.blank? ? reference.amount : reference.amount_payment, row.currency)}\t",
                  "#{row.notes.squish unless row.notes.blank?}\t",
                  "#{si_date_format reference.first_etd_date}\t",
                  "#{si_date_format row.payment_date}\t",
                  "#{row.status_info}\t",
                  "#{money_with_currency_format(reference.amount_misc, reference.currency)}\t",
                  "#{money_with_currency_format(reference.amount_invoice, reference.currency)}\t"
                ]
        body
      end
    end
  end

  # def report_list_payment_tax(reference, format)
  #   if format == "pdf"
  #     row = reference.shipping_instruction
  #     Rails.cache.fetch(["report-list-payment-tax-pdf", row, reference]) do
  #       body = []
  #       body = [  "",
  #                 "<td>#{reference.carrier_name}</td>",
  #                 "<td>#{row.ibl_ref_with_status}</td>",
  #                 "<td style=\"text-align:right\">#{money_with_currency_format(reference.amount, reference.currency)}</td>",
  #                 "<td>#{reference.tax_no}</td>",
  #                 "<td>#{monthly_format reference.tax_issued}</td>",
  #                 "<td>#{reference.paid_status}</td>" ]
  #       body
  #     end
  #   elsif format == "xls"
  #     row = reference.shipping_instruction
  #     Rails.cache.fetch(["report-list-payment-tax-xls", row, reference]) do
  #       body = []
  #       body = [  "",
  #                 "#{reference.carrier_name}\t",
  #                 "#{row.ibl_ref_with_status}\t",
  #                 "#{money_with_currency_format(reference.amount, reference.currency)}\t",
  #                 "#{reference.tax_no}\t",
  #                 "#{monthly_format reference.tax_issued}\t",
  #                 "#{reference.paid_status}\t" ]
  #       body
  #     end
  #   end
  # end

  def report_list_payment_tax(reference, type, format)
    if format == "pdf"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-payment-tax-pdf", row, reference, type]) do
        body = []
        amount_tax = 0
        tax_no = ''
        tax_issued = ''
        invoice_no = ''
        status = ''

        if type == "VAT 10%"
          amount_tax = reference.vat_10
          tax_no = reference.vat_10_tax_no
          tax_issued = reference.vat_10_tax_issued
          invoice_no = reference.vat_10_invoice_no
          status = reference.vat_10_status_text
        elsif type == "VAT 1%"
          amount_tax = reference.vat_1
          tax_no = reference.vat_1_tax_no
          tax_issued = reference.vat_1_tax_issued
          invoice_no = reference.vat_1_invoice_no
          status = reference.vat_1_status_text
        elsif type == "PPH 23"
          amount_tax = reference.pph_23
          tax_no = reference.pph_23_tax_no
          tax_issued = reference.pph_23_tax_issued
          invoice_no = reference.pph_23_invoice_no
          status = reference.pph_23_status_text
        end

        body = [  "",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{reference.carrier}</td>",
                  "<td>#{type}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(amount_tax, 'IDR')}</td>",
                  "<td>#{tax_no}</td>",
                  "<td>#{si_date_format tax_issued}</td>",
                  "<td>#{si_date_format reference.payment_date}</td>",
                  "<td>#{invoice_no}</td>",
                  "<td>#{reference.paid_status}</td>",
                  "<td>#{status}</td>" ]
        body
      end
    elsif format == "xls"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-payment-tax-xls", row, reference, type]) do
        body = []
        amount_tax = 0
        tax_no = ''
        tax_issued = ''
        invoice_no = ''
        status = ''

        if type == "VAT 10%"
          amount_tax = reference.vat_10
          tax_no = reference.vat_10_tax_no
          tax_issued = reference.vat_10_tax_issued
          invoice_no = reference.vat_10_invoice_no
          status = reference.vat_10_status_text
        elsif type == "VAT 1%"
          amount_tax = reference.vat_1
          tax_no = reference.vat_1_tax_no
          tax_issued = reference.vat_1_tax_issued
          invoice_no = reference.vat_1_invoice_no
          status = reference.vat_1_status_text
        elsif type == "PPH 23"
          amount_tax = reference.pph_23
          tax_no = reference.pph_23_tax_no
          tax_issued = reference.pph_23_tax_issued
          invoice_no = reference.pph_23_invoice_no
          status = reference.pph_23_status_text
        end

        body = [  "",
                  "#{row.ibl_ref_with_status}\t",
                  "#{reference.carrier}\t",
                  "#{type}\t",
                  "#{money_with_currency_format(amount_tax, 'IDR')}\t",
                  "#{tax_no}\t",
                  "#{si_date_format tax_issued}\t",
                  "#{si_date_format reference.payment_date}\t",
                  "#{invoice_no}\t",
                  "#{reference.paid_status}\t",
                  "#{status}\t" ]
        body
      end
    end
  end

  def report_list_payment_deposit(row, format)
    if format == "pdf"
      Rails.cache.fetch(["report-list-payment-deposit-pdf", row]) do
        references = row.payment_references
        deposits = row.payment_deposits

        deposit_usd = 0
        deposit_idr = 0

        references.each do |reference|
          if reference.currency == "USD"
            deposit_usd += reference.amount_deposit.to_f
          else
            deposit_idr += reference.amount_deposit.to_f
          end
        end

        use_deposit_usd = 0
        use_deposit_idr = 0

        deposits.each do |deposit|
          if deposit.currency == "USD"
            use_deposit_usd += deposit.amount.to_f
          else
            use_deposit_idr += deposit.amount.to_f
          end
        end

        amount = []
        amount_usd = deposit_usd.to_f - use_deposit_usd.to_f
        amount_idr = deposit_idr.to_f - use_deposit_idr.to_f
        amount.push "#{money_with_currency_format(amount_usd, 'USD')}" unless amount_usd == 0
        amount.push "#{money_with_currency_format(amount_idr, 'IDR')}" unless amount_idr == 0

        body = []
        body = [  "",
                  "<td>#{row.carrier}</td>",
                  "<td>#{row.master_bl_no}</td>",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td style=\"text-align:right\">#{amount.join('<br>').html_safe}</td>" ]
        body
      end
    elsif format == "xls"
      Rails.cache.fetch(["report-list-payment-deposit-xls", row]) do
        references = row.payment_references
        deposits = row.payment_deposits

        deposit_usd = 0
        deposit_idr = 0

        references.each do |reference|
          if reference.currency == "USD"
            deposit_usd += reference.amount_deposit.to_f
          else
            deposit_idr += reference.amount_deposit.to_f
          end
        end

        use_deposit_usd = 0
        use_deposit_idr = 0

        deposits.each do |deposit|
          if deposit.currency == "USD"
            use_deposit_usd += deposit.amount.to_f
          else
            use_deposit_idr += deposit.amount.to_f
          end
        end

        amount = []
        amount_usd = deposit_usd.to_f - use_deposit_usd.to_f
        amount_idr = deposit_idr.to_f - use_deposit_idr.to_f
        amount.push "#{money_with_currency_format(amount_usd, 'USD')}" unless amount_usd == 0
        amount.push "#{money_with_currency_format(amount_idr, 'IDR')}" unless amount_idr == 0

        body = []
        body = [  "",
                  "#{row.carrier}\t",
                  "#{row.master_bl_no}\t",
                  "#{row.ibl_ref_with_status}\t",
                  "#{amount.join(', ')}\t" ]
        body
      end
    end
  end

  def report_list_cc_list_invoice(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-list-invoice-pdf", row, reference]) do
        amount_usd = money_format(reference.total_invoice) if reference.currency_code == "USD"
        amount_idr = money_format(reference.total_invoice) if reference.currency_code == "IDR"

        body = []
        body = [  "",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{reference.customer}</td>",
                  "<td>#{row.shipper_company_name}</td>",
                  "<td>#{row.shipper_reference}</td>",
                  "<td>#{row.master_bl_no}</td>",
                  "<td>#{reference.invoice_no_with_status}</td>",
                  "<td>#{reference.invoice_details.map{|p| p.volume}.sum(&:to_f)}</td>",
                  "<td>#{row.final_destination}</td>",
                  "<td style=\"text-align:right\">#{amount_usd unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{amount_idr unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(reference.freight, reference.currency_code) unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(reference.vat_10, reference.currency_code) unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(reference.vat_1, reference.currency_code) unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(reference.pph_23, reference.currency_code) unless reference.is_canceled?}</td>",
                  "<td>#{si_date_format reference.etd}</td>",
                  "<td>#{si_date_format reference.due_date}</td>",
                  "<td>#{si_date_format reference.payment_date}</td>",
                  "<td>#{reference.payment_status_text}</td>",
                  "<td>#{simple_format reference.payment_note}</td>" ]
        body
      # end
    elsif format == "xls"
      row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-list-invoice-xls", row, reference]) do
        amount_usd = money_format(reference.total_invoice) if reference.currency_code == "USD"
        amount_idr = money_format(reference.total_invoice) if reference.currency_code == "IDR"

        body = []
        body = [  "",
                  "#{row.ibl_ref_with_status}\t",
                  "#{reference.customer}\t",
                  "#{row.shipper_company_name}\t",
                  "#{row.shipper_reference}\t",
                  "#{row.master_bl_no}\t",
                  "#{reference.invoice_no_with_status}\t",
                  "#{reference.invoice_details.map{|p| p.volume}.sum(&:to_f)}\t",
                  "#{row.final_destination}\t",
                  "#{amount_usd unless reference.is_canceled?}\t",
                  "#{amount_idr unless reference.is_canceled?}\t",
                  "#{money_with_currency_format(reference.freight, reference.currency_code) unless reference.is_canceled?}\t",
                  "#{money_with_currency_format(reference.vat_10, reference.currency_code) unless reference.is_canceled?}\t",
                  "#{money_with_currency_format(reference.vat_1, reference.currency_code) unless reference.is_canceled?}\t",
                  "#{money_with_currency_format(reference.pph_23, reference.currency_code) unless reference.is_canceled?}\t",
                  "#{si_date_format reference.etd}\t",
                  "#{si_date_format reference.due_date}\t",
                  "#{si_date_format reference.payment_date}\t",
                  "#{reference.status_text(reference.status_payment)}\t",
                  "#{reference.notes.squish unless reference.notes.blank?}\t" ]
        body
      # end
    end
  end

  def report_list_cc(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-cc-pdf", row, reference, reference.close_payment_histories.last]) do
        amount_usd = money_format(reference.grand_total) if reference.currency_code == "USD"
        amount_idr = money_format(reference.grand_total) if reference.currency_code == "IDR"

        body = []
        body = [  "",
                  "<td>#{reference.invoice_inquiry.try(:close_ref)}</td>",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{reference.customer}</td>",
                  "<td>#{reference.shipper_company_name}</td>",
                  "<td>#{reference.shipper_reference}</td>",
                  "<td>#{reference.master_bl_no}</td>",
                  "<td>#{reference.invoice_no_with_status}</td>",
                  "<td>#{reference.volume}</td>",
                  "<td>#{reference.port_of_loading}</td>",
                  "<td>#{reference.final_destination}</td>",
                  "<td style=\"text-align:right\">#{amount_usd unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{amount_idr unless reference.is_canceled?}</td>",
                  "<td>#{si_date_format reference.invoice_date}</td>",
                  "<td>#{si_date_format reference.etd}</td>",
                  "<td>#{si_date_format reference.due_date}</td>",
                  "<td>#{si_date_format reference.payment_date}</td>",
                  "<td>#{reference.payment_status_text}</td>",
                  "<td>#{simple_format reference.payment_note}</td>" ]
        body
      end
    elsif format == "xls"
      row = reference.shipping_instruction
      Rails.cache.fetch(["report-list-cc-xls", row, reference, reference.close_payment_histories.last]) do
        amount_usd = money_format(reference.grand_total) if reference.currency_code == "USD"
        amount_idr = money_format(reference.grand_total) if reference.currency_code == "IDR"

        body = []
        body = [  "",
                  "#{reference.invoice_inquiry.try(:close_ref)}\t",
                  "#{row.ibl_ref_with_status}\t",
                  "#{reference.customer}\t",
                  "#{reference.shipper_company_name}\t",
                  "#{reference.shipper_reference}\t",
                  "#{reference.master_bl_no}\t",
                  "#{reference.invoice_no_with_status}\t",
                  "#{reference.volume}\t",
                  "#{reference.port_of_loading}\t",
                  "#{reference.final_destination}\t",
                  "#{amount_usd unless reference.is_canceled?}\t",
                  "#{amount_idr unless reference.is_canceled?}\t",
                  "#{si_date_format reference.invoice_date}\t",
                  "#{si_date_format reference.etd}\t",
                  "#{si_date_format reference.due_date}\t",
                  "#{si_date_format reference.payment_date}\t",
                  "#{reference.payment_status_text}\t",
                  "#{reference.payment_note.squish unless reference.payment_note.blank?}\t" ]
        body
      end
    end
  end

  def report_list_cc_breakdown(reference, format)
    if format == "pdf"
      row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-list-invoice-pdf", row, reference]) do
        amount_usd = money_format(reference.grand_total) if reference.currency_code == "USD"
        amount_idr = money_format(reference.grand_total) if reference.currency_code == "IDR"

        body = []
        body = [  "",
                  "<td>#{row.ibl_ref_with_status}</td>",
                  "<td>#{reference.shipper_company_name}</td>",
                  "<td>#{reference.customer}</td>",
                  "<td>#{reference.invoice_no_with_status}</td>",
                  "<td style=\"text-align:right\">#{amount_usd unless reference.is_canceled?}</td>",
                  "<td style=\"text-align:right\">#{amount_idr unless reference.is_canceled?}</td>",
                  "<td>#{si_date_format reference.etd}</td>",
                  "<td>#{si_date_format reference.due_date}</td>" ]
        body
      # end
    elsif format == "xls"
      row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-list-invoice-xls", row, reference]) do
        amount_usd = money_format(reference.grand_total) if reference.currency_code == "USD"
        amount_idr = money_format(reference.grand_total) if reference.currency_code == "IDR"

        body = []
        body = [  "",
                  "#{row.ibl_ref_with_status}\t",
                  "#{reference.shipper_company_name}\t",
                  "#{reference.customer}\t",
                  "#{reference.invoice_no_with_status}\t",
                  "#{amount_usd unless reference.is_canceled?}\t",
                  "#{amount_idr unless reference.is_canceled?}\t",
                  "#{si_date_format reference.etd}\t",
                  "#{si_date_format reference.due_date}\t" ]
        body
      # end
    end
  end

  def report_list_cc_short_paid(reference, format)
    if format == "pdf"
      # row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-short-paid-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{si_date_format reference.close_payment.payment_date}</td>",
                  "<td>#{reference.close_payment.customer}</td>",
                  "<td>#{reference.close_payment.ibl_ref}</td>",
                  "<td>#{reference.close_payment.invoice_no}</td>",
                  # "<td style=\"text-align:right\">#{money_with_currency_format(reference.short_paid, reference.close_payment.currency)}</td>",
                  "<td style=\"text-align:right\">#{money_format(reference.short_paid) if reference.currency_2 == "IDR"}</td>",
                  "<td style=\"text-align:right\">#{money_format(reference.short_paid) if reference.currency_2 == "USD"}</td>",
                  "<td>#{reference.short_paid_status_text}</td>",
                  "<td>#{si_date_format reference.short_paid_closing_date}</td>",
                  "<td>#{simple_format reference.short_paid_note}</td>" ]
        body
      # end
    elsif format == "xls"
      # row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-short-paid-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{si_date_format reference.close_payment.payment_date}\t",
                  "#{reference.close_payment.customer}\t",
                  "#{reference.close_payment.ibl_ref}\t",
                  "#{reference.close_payment.invoice_no}\t",
                  # "#{money_with_currency_format(reference.short_paid, reference.close_payment.currency)}\t",
                  "#{money_format(reference.short_paid) if reference.currency_2 == "IDR"}\t",
                  "#{money_format(reference.short_paid) if reference.currency_2 == "USD"}\t",
                  "#{reference.short_paid_status_text}\t",
                  "#{si_date_format reference.short_paid_closing_date}\t",
                  "#{reference.short_paid_note.squish unless reference.short_paid_note.blank?}\t" ]
        body
      # end
    end
  end

  def report_list_cc_deposit(reference, format)
    if format == "pdf"
      # row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-deposit-pdf", row, reference]) do
        body = []
        body = [  "",
                  "<td>#{si_date_format reference.close_payment.payment_date}</td>",
                  "<td>#{reference.close_payment.customer}</td>",
                  "<td>#{reference.close_payment.ibl_ref}</td>",
                  "<td>#{reference.close_payment.invoice_no}</td>",
                  # "<td style=\"text-align:right\">#{money_with_currency_format(reference.deposit, reference.close_payment.currency)}</td>",
                  "<td style=\"text-align:right\">#{money_with_currency_format(reference.deposit, 'IDR')}</td>",
                  "<td>#{reference.deposit_status_text}</td>",
                  "<td>#{si_date_format reference.deposit_closing_date}</td>",
                  "<td>#{simple_format reference.deposit_note}</td>" ]
        body
      # end
    elsif format == "xls"
      # row = reference.shipping_instruction
      # Rails.cache.fetch(["report-list-cc-deposit-xls", row, reference]) do
        body = []
        body = [  "",
                  "#{si_date_format reference.close_payment.payment_date}\t",
                  "#{reference.close_payment.customer}\t",
                  "#{reference.close_payment.ibl_ref}\t",
                  "#{reference.close_payment.invoice_no}\t",
                  # "#{money_with_currency_format(reference.deposit, reference.close_payment.currency)}\t",
                  "#{money_with_currency_format(reference.deposit, 'IDR')}\t",
                  "#{reference.deposit_status_text}\t",
                  "#{si_date_format reference.deposit_closing_date}\t",
                  "#{reference.deposit_note.squish unless reference.deposit_note.blank?}\t" ]
        body
      # end
    end
  end

  def report_list_cr(row, format)
    if format == "pdf"
      Rails.cache.fetch(["report-list-cr-pdf", row]) do
        body = []
        if row.cost_revenue.blank?
          body = [  "",
                    "<td>#{row.ibl_ref_with_status}</td>",
                    "<td>#{row.master_bl_no}</td>",
                    "<td>#{row.carrier}</td>",
                    "<td>#{row.shipper_reference}</td>",
                    "<td>#{row.shipper_company_name}</td>",
                    "<td>#{row.consignee_company_name}</td>",
                    "<td>#{row.first_vessel_name}</td>",
                    "<td>#{si_date_format row.first_etd_date}</td>",
                    "<td>#{row.port_of_loading}</td>",
                    "<td>#{row.port_of_discharge}</td>",
                    "<td>#{row.final_destination}</td>",
                    "<td>#{row.volume}</td>",
                    "<td>#{}</td>",
                    "<td>No Status</td>",
                    "<td>#{row.trade}</td>",
                    "<td style=\"text-align:right\">#{}</td>",
                    "<td style=\"text-align:right\">#{}</td>",
                    "<td style=\"text-align:right\">#{}</td>",
                    "<td style=\"text-align:right\">#{}</td>" ]
        else
          cost_revenue = row.cost_revenue
          body = [  "",
                    "<td>#{cost_revenue.ibl_ref_with_status}</td>",
                    "<td>#{cost_revenue.master_bl_no}</td>",
                    "<td>#{cost_revenue.carrier_name}</td>",
                    "<td>#{cost_revenue.shipper_reference}</td>",
                    "<td>#{cost_revenue.shipper_company_name}</td>",
                    "<td>#{cost_revenue.consignee_company_name}</td>",
                    "<td>#{cost_revenue.vessel_name}</td>",
                    "<td>#{si_date_format cost_revenue.first_etd_date}</td>",
                    "<td>#{cost_revenue.port_of_loading}</td>",
                    "<td>#{cost_revenue.port_of_discharge}</td>",
                    "<td>#{cost_revenue.final_destination}</td>",
                    "<td>#{cost_revenue.volume}</td>",
                    "<td>#{cost_revenue.owner_name}</td>",
                    "<td>#{cost_revenue.status_text.join("<br>")}</td>",
                    "<td>#{cost_revenue.trade}</td>",
                    "<td style=\"text-align:right\">#{sell_usd(cost_revenue).join('<br>')}</td>",
                    "<td style=\"text-align:right\">#{sell_idr(cost_revenue).join('<br>')}</td>",
                    "<td style=\"text-align:right\">#{cost_usd(cost_revenue).join('<br>')}</td>",
                    "<td style=\"text-align:right\">#{cost_idr(cost_revenue).join('<br>')}</td>" ]
        end
        body
      end
    elsif format == "xls"
      Rails.cache.fetch(["report-list-cr-xls", row]) do
        body = []
        if row.cost_revenue.blank?
          body = [  "",
                    "#{row.ibl_ref_with_status}\t",
                    "#{row.master_bl_no}\t",
                    "#{row.carrier}\t",
                    "#{row.shipper_reference}\t",
                    "#{row.shipper_company_name}\t",
                    "#{row.consignee_company_name}\t",
                    "#{row.first_vessel_name}\t",
                    "#{si_date_format row.first_etd_date}\t",
                    "#{row.port_of_loading}\t",
                    "#{row.port_of_discharge}\t",
                    "#{row.final_destination}\t",
                    "#{row.volume}\t",
                    "#{}\t",
                    "No Status\t",
                    "#{row.trade}\t",
                    "#{}\t",
                    "#{}\t",
                    "#{}\t",
                    "#{}\t" ]
        else
          cost_revenue = row.cost_revenue
          body = [  "",
                    "#{cost_revenue.ibl_ref_with_status}\t",
                    "#{cost_revenue.master_bl_no}\t",
                    "#{cost_revenue.carrier_name}\t",
                    "#{cost_revenue.shipper_reference}\t",
                    "#{cost_revenue.shipper_company_name}\t",
                    "#{cost_revenue.consignee_company_name}\t",
                    "#{cost_revenue.vessel_name}\t",
                    "#{si_date_format cost_revenue.first_etd_date}\t",
                    "#{cost_revenue.port_of_loading}\t",
                    "#{cost_revenue.port_of_discharge}\t",
                    "#{cost_revenue.final_destination}\t",
                    "#{cost_revenue.volume}\t",
                    "#{cost_revenue.owner_name}\t",
                    "#{cost_revenue.status_text.join(', ')}\t",
                    "#{cost_revenue.trade}\t",
                    "#{sell_usd(cost_revenue).join(', ')}\t",
                    "#{sell_idr(cost_revenue).join(', ')}\t",
                    "#{cost_usd(cost_revenue).join(', ')}\t",
                    "#{cost_idr(cost_revenue).join(', ')}\t" ]
        end
        body
      end
    end
  end
end
