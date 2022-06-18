class BLServices
  def initialize(bill_of_lading)
    @bill_of_lading = bill_of_lading
  end

  def cancel!
    @bill_of_lading.class.transaction do
      cancel_bill_of_lading!(true)
      cancel_invoices!(true)
      cancel_debit_notes!(true)
      cancel_notes!(true)
    end
  end

  def uncancel!
    @bill_of_lading.class.transaction do
      cancel_bill_of_lading!(false)
      cancel_invoices!(false)
      cancel_debit_notes!(false)
      cancel_notes!(false)
    end
  end

  def not_yet!
    @bill_of_lading.class.transaction do
      delivery_doc_bill_of_lading!(false)
    end
  end

  def done!
    @bill_of_lading.class.transaction do
      delivery_doc_bill_of_lading!(true)
    end
  end

  def get_invoice_data
    # data = Array.new
    bl = @bill_of_lading
    invoice = bl.bill_of_lading_invoices.first

    if invoice.nil?
      @get_invoice_data = {success: false, message: "Calculate Invoice Not Listed"}
    else
      data = []

      @get_invoice_data = begin
        # invoice.volume_items.each do |item|
        #   data << { description: item.description, volume: item.volume.to_f, amount: item.amount.to_f }
        # end
        # invoice.shipper_items.each do |item|
        #   data << { description: item.description, volume: item.volume.to_f, amount: item.amount.to_f }
        # end
        # invoice.carrier_items.each do |item|
        #   data << { description: item.description, volume: item.volume.to_f, amount: item.amount.to_f }
        # end
        # invoice.active_items.each do |item|
        #   data << { description: item.description, volume: item.volume.to_f, amount: item.amount.to_f }
        # end
        # invoice.fixed_items.each do |item|
        #   data << { description: item.description, volume: item.volume.to_f, amount: item.amount.to_f }
        # end
        invoice.bill_of_lading_items.each do |item|
          data << { description: item.description, volume: item.volume.to_f, amount: item.amount.to_f }
        end

        {success: true, rate: invoice.rate, invoice: data}
      end
    end

    # !data.blank? ? data : ""
    @get_invoice_data
  end

  def get_invoice_data(currency)
    # data = Array.new
    bl = @bill_of_lading
    invoice = bl.bill_of_lading_invoices.first

    if invoice.nil?
      @get_invoice_data = {success: false, message: "Invoice Not Listed"}
    else
      data = []

      @get_invoice_data = begin
        invoice.bill_of_lading_items.each do |item|
          amount = item.amount.to_f
          # amount /= invoice.rate if currency == "USD" && invoice.rate != 0
          data << { description: item.description, volume: item.volume.to_f, amount: amount }
        end

        {success: true, rate: invoice.rate, invoice: data}
      end
    end

    # !data.blank? ? data : ""
    @get_invoice_data
  end
  # def get_sell_comparison_data
  #   # data = Array.new
  #   bl = @bill_of_lading
  #   invoice = bl.bill_of_lading_invoice
  #   data = []
  #   unless invoice.blank?
  #     # raise invoice.bill_of_lading_items.inspect
  #     invoice.volume_items.each do |item|
  #       data << { description: item.description, volume: item.volume.to_f, amount_usd: item.amount_usd.to_f, amount_idr: item.amount_idr.to_f, total_after_tax: item.total_after_tax.to_f, item_type: item.item_type }
  #     end
  #     invoice.shipper_items.each do |item|
  #       data << { description: item.description, volume: item.volume.to_f, amount_usd: item.amount_usd.to_f, amount_idr: item.amount_idr.to_f, total_after_tax: item.total_after_tax.to_f, item_type: item.item_type }
  #     end
  #     invoice.carrier_items.each do |item|
  #       data << { description: item.description, volume: item.volume.to_f, amount_usd: item.amount_usd.to_f, amount_idr: item.amount_idr.to_f, total_after_tax: item.total_after_tax.to_f, item_type: item.item_type }
  #     end
  #     invoice.active_items.each do |item|
  #       data << { description: item.description, volume: item.volume.to_f, amount_usd: item.amount_usd.to_f, amount_idr: item.amount_idr.to_f, total_after_tax: item.total_after_tax.to_f, item_type: item.item_type }
  #     end
  #     invoice.fixed_items.each do |item|
  #       data << { description: item.description, volume: item.volume.to_f, amount_usd: item.amount_usd.to_f, amount_idr: item.amount_idr.to_f, total_after_tax: item.total_after_tax.to_f, item_type: item.item_type }
  #     end
  #   end
  #   !data.blank? ? data : ""
  # end

  private
  def cancel_bill_of_lading!(value)
    @bill_of_lading.update_attribute(:is_cancel, value)
  end

  def cancel_invoices!(value)
    @bill_of_lading.invoices.each { |invoice| invoice.update_attribute(:is_cancel, value) }
  end

  def cancel_debit_notes!(value)
    @bill_of_lading.debit_notes.each { |debit_note| debit_note.update_attribute(:is_cancel, value) }
  end

  def cancel_notes!(value)
    @bill_of_lading.notes.each { |note| note.update_attribute(:is_cancel, value) }
  end

  def delivery_doc_bill_of_lading!(value)
    @bill_of_lading.update_attribute(:delivery_doc, value)  
  end
end