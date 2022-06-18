class InvoicesController < ApplicationController
  # layout "print", :only => [ :print ]
  
  before_filter :authorize, except: [:paid, :unpaid] # if Rails.env.production?
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :print, :update_status, :cancel, :uncancel]
  before_action :validate_edit_print, only: [:edit, :update, :print]
  before_action :load_description, only: [:new, :edit, :create, :update, :create_invoice]

  before_action :enable_edit_invoice, only: [:edit, :update, :update_status, :cancel, :uncancel]

  def index
    if params[:id]
      @invoices = Invoice.where(bill_of_lading_id: params[:id])
    elsif params[:SI] && params[:query]
      arr_si = params[:SI].split(",")
      shipping_instruction = ShippingInstruction.where(si_no: arr_si)
      bill_of_ladings = BillOfLanding.where(shipping_instruction_id: shipping_instruction)
      @invoices = Invoice.where("bill_of_lading_id IN (?) AND no_invoice LIKE ? AND status = 0", bill_of_ladings, "%" + params[:query] + "%")
    else
      @invoices = Invoice.includes(:bill_of_lading).order("bill_of_ladings.bl_number DESC")
    end
    respond_to do |format|
      format.html 
      format.json
    end
  end

  def show
    # respond_to do |format|
    #   format.html { 
    #     render 
    #   }
    #   format.pdf {
    #     validate_edit_print
    #     html = render_to_string(:layout => false , :action => "show-pdf.html.erb", :formats => [:html], :handler => [:erb])
    #     kit = PDFKit.new(html, :margin_top => "0.25cm", :margin_left => "1cm", :margin_right => "1cm", :margin_bottom => "1cm")
    #     kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
    #     send_data(kit.to_pdf, :filename => @invoice.no_invoice + ".pdf", :type => 'application/pdf', :disposition  => "inline")
    #     return # to avoid double render call
    #   }
    # end
    respond_to do |format|
      format.html { 
        render 
      }
      format.pdf {
        validate_edit_print
        html = render_to_string(:layout => false , :action => "../invoices/show-pdf.html.erb", :formats => [:html], :handler => [:erb])
        kit = PDFKit.new(html, :margin_top => "0.25cm", :margin_left => "1cm", :margin_right => "1cm", :margin_bottom => "1cm")
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => @invoice.invoice_no + ".pdf", :type => 'application/pdf', :disposition  => "inline")
        return # to avoid double render call
      }
    end
  end

  def new
    @invoice = Invoice.new
    @invoice.no_invoice = @invoice.generate_invoice_number
    3.times { @invoice.invoice_details.build }
  end

  def edit
    @invoice.to_shipper = @invoice.bill_of_lading.shipper.company_name if @invoice.to_shipper.nil?
    @invoice.vessel = @invoice.bill_of_lading.feeder_vessel if @invoice.vessel.nil?
    @invoice.destination = @invoice.bill_of_lading.final_destination if @invoice.destination.nil?
    @invoice.bl_ibl_no = [@invoice.bill_of_lading.master_bl_no, @invoice.bill_of_lading.bl_number].join(" / ") if @invoice.bl_ibl_no.nil?
    @invoice.shipper_ref = @invoice.bill_of_lading.shipping_instruction.shipper_reference if @invoice.shipper_ref.nil?
    @invoice.etd = @invoice.bill_of_lading.shipping_instruction.vessels.first.etd_date if @invoice.etd.nil?
    @invoice.eta = @invoice.bill_of_lading.shipping_instruction.vessels.last.eta_date if @invoice.eta.nil?

    unless params[:iid].blank?
      @invoice.invoice_details.each do |detail|
        detail._destroy = 1
      end
      
      if calculate_invoice = BillOfLadingInvoice.find_by(id: params[:iid])
        redirect_to edit_invoice_path(@invoice), notice: "Invoice #{@invoice.invoice_no} with #{calculate_invoice.shipping_instruction.ibl_ref} was not connected." unless calculate_invoice.shipping_instruction.ibl_ref == @invoice.ibl_ref
        
        currency = @invoice.currency_code
        
        @invoice.vat_10 = calculate_invoice.invoice_vat_10(currency)
        @invoice.vat_1 = calculate_invoice.invoice_vat_1(currency)
        @invoice.pph_23 = calculate_invoice.invoice_pph_23(currency)
        @invoice.rate = calculate_invoice.rate

        @invoice.default_total_amount = calculate_invoice.invoice_total_invoice(currency)
        @invoice.default_vat_10 = calculate_invoice.invoice_vat_10(currency)
        @invoice.default_vat_1 = calculate_invoice.invoice_vat_1(currency)
        @invoice.default_total_include_vat = @invoice.default_total_include_vat
        @invoice.default_pph_23 = calculate_invoice.invoice_pph_23(currency)
        @invoice.default_total_after_pph_23 = @invoice.default_total_after_pph_23
        @invoice.default_rate = calculate_invoice.rate

        calculate_invoice.bill_of_lading_items.each do |item|
          @invoice.invoice_details.build({ description: item.description, volume: item.volume.to_f, amount: item.invoice_amount(currency), default_amount: item.invoice_amount(currency) })
        end
      # else
      #   (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
      end
      3.times { @invoice.invoice_details.build } if @invoice.invoice_details.map{|p| p._destroy == 1 ? 0 : 1 }.sum(&:to_i) == @invoice.invoice_details.size
    end

    if params[:layout] == "false"
      render :json => {'success' => true, 'message' => render_to_string(:action => "edit",:layout => false)}.to_json and return
    end
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.status = 0

    while Invoice.exists? no_invoice: @invoice.no_invoice  do
      @invoice.no_invoice = @invoices.generate_invoice_number
    end

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully created.' 
    else
      3.times { @invoice.invoice_details.build }
      render action: 'new' 
    end
  end

  def update
    if @invoice.update_attributes(invoice_params)
      redirect_to @invoice, notice: 'Invoice was successfully updated.' 
    else
      render action: 'edit' 
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_url 
  end

  # def create_invoice
  #   bl = BillOfLading.find(params[:bid])
  #   si = bl.shipping_instruction

  #   # if si.is_complete?
  #   #   vessel = bl.shipping_instruction.vessels.first
  #   #   @invoice = Invoice.new(
  #   #     :bill_of_lading_id => bl.id, 
  #   #     :invoice_date => Date.today, 
  #   #     :due_date => vessel.etd_date + bl.shipper.credit_term.to_i,
  #   #     :to_shipper => bl.shipper.company_name, 
  #   #     :vessel => bl.feeder_vessel,
  #   #     :destination => bl.final_destination, 
  #   #     :bl_ibl_no => [bl.master_bl_no, bl.bl_number].join(" / "),
  #   #     :shipper_ref => bl.shipping_instruction.shipper_reference, 
  #   #     :etd => bl.shipping_instruction.vessels.first.etd_date,
  #   #     :eta => bl.shipping_instruction.vessels.last.eta_date,
  #   #     :head_letter => params[:letter].upcase
  #   #   )
  #   #   @invoice.no_invoice = @invoice.generate_invoice_number
  #   #   3.times { @invoice.invoice_details.build }

  #   #   if @invoice.valid?
  #   #     @invoice.save
  #   #     redirect_to edit_invoice_path @invoice, :layout => false
  #   #   end
  #   # else
  #   #   output = {'success' => false, 'message' => "Please complete SI data, Thank you. Go to <a href=\"#{ edit_shipping_instruction_path(si) }\">Update SI</a>"}
  #   #   render :json => output.to_json and return
  #   # end
  #   json_result = si.is_complete
  #   array_result = json_result.to_a

  #   if array_result[0][1]
  #     # vessel = bl.shipping_instruction.vessels.first
  #     # details = []
  #     # bl.shipping_instruction.bill_of_lading_invoice.bill_of_lading_items.each do |item|
  #     #   details << { description: item.description, amount: item.unit_price.to_f, volume: item.volume.to_f }
  #     # end

  #     # @invoice = Invoice.new(
  #     #   :bill_of_lading_id => bl.id, 
  #     #   :invoice_date => Date.today, 
  #     #   :due_date => vessel.etd_date + bl.shipping_instruction.shipper.credit_term.to_i,
  #     #   :to_shipper => bl.shipping_instruction.shipper.company_name, 
  #     #   :vessel => bl.shipping_instruction.feeder_vessel,
  #     #   :port_of_loading => bl.shipping_instruction.port_of_loading, 
  #     #   :destination => bl.shipping_instruction.final_destination, 
  #     #   :bl_no => bl.shipping_instruction.master_bl_no,
  #     #   :ibl_no => bl.shipping_instruction.si_no,
  #     #   :shipper_ref => bl.shipping_instruction.shipper_reference, 
  #     #   :etd => bl.shipping_instruction.vessels.first.etd_date,
  #     #   :eta => bl.shipping_instruction.vessels.last.eta_date,
  #     #   :head_letter => params[:letter].upcase, 
  #     #   :invoice_details_attributes => details
  #     # )
  #     # @invoice.no_invoice = @invoice.generate_invoice_number
  #     # (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
  #     # @invoice.invoice_other_details.build([ 
  #     #   { description: "VAT 10%" },
  #     #   { description: "VAT 1%" },
  #     #   { description: "Total Including VAT" },
  #     #   { description: "PPH 23" },
  #     #   { description: "Total After PPH 23" }
  #     # ])
  #     # @invoice.build_invoice_rate( description: "RATE" )
  #     # # if @invoice.valid?
  #     # #   @invoice.save
  #     # #   redirect_to edit_invoice_path @invoice, :layout => false
  #     # # end



  #     # vessel = si.vessels.first
  #     # active = []
  #     # fixed = []

  #     # si.bill_of_lading_invoice.bill_of_lading_items.where.not(item_type: 0).each do |item|
  #     #   active << { description: item.description, amount: item.unit_price.to_f, volume: item.volume.to_f, item_type: item.item_type }
  #     # end

  #     # # si.bill_of_lading_invoice.fixed_items.each do |item|
  #     # #   fixed << { description: item.description, amount: item.unit_price.to_f, volume: item.volume.to_f, item_type: item.item_type }
  #     # # end
      
  #     # @invoice = Invoice.new(
  #     #   :bill_of_lading_id => bl.id, 
  #     #   :invoice_date => Date.today, 
  #     #   :due_date => vessel.etd_date + si.shipper.credit_term.to_i,
  #     #   :to_shipper => si.shipper.company_name, 
  #     #   :vessel => si.feeder_vessel,
  #     #   :port_of_loading => si.port_of_loading, 
  #     #   :destination => si.final_destination, 
  #     #   :bl_no => si.master_bl_no,
  #     #   :ibl_no => si.si_no,
  #     #   :shipper_ref => si.shipper_reference, 
  #     #   :etd => si.vessels.first.etd_date,
  #     #   :eta => si.vessels.last.eta_date,
  #     #   :head_letter => params[:letter].upcase, 
  #     #   # :invoice_details_attributes => details
  #     #   :active_items_attributes => active
  #     # )
  #     # @invoice.no_invoice = @invoice.generate_invoice_number
  #     # (3-@invoice.active_items.size).times { @invoice.active_items.build }
  #     # @invoice.fixed_items.build([ 
  #     #   { description: "VAT 10%", volume: 1, item_type: 'fixed' },
  #     #   { description: "VAT 1%", volume: 1, item_type: 'fixed' },
  #     #   { description: "Total Including VAT", volume: 1, item_type: 'fixed' },
  #     #   { description: "PPH 23", volume: 1, item_type: 'fixed' },
  #     #   { description: "Total After PPH 23", volume: 1, item_type: 'fixed' },
  #     #   { description: "RATE", volume: 1, item_type: 'fixed' }
  #     # ]) if @invoice.fixed_items.blank?
  #     # @invoice.build_invoice_rate( description: "RATE" )


  #     vessel = si.vessels.first
  #     details = []

  #     # si.bill_of_lading_invoice.bill_of_lading_items.each do |item|
  #     #   details << { description: item.description, amount: item.unit_price.to_f, volume: item.volume.to_f, item_type: item.item_type }
  #     # end
      
  #     services = BLServices.new(bl)
  #     # json_result = services.get_invoice_data
  #     # array_result = json_result.to_a
  #     # details = array_result[1][1] if array_result[0][1]

  #     @invoice = Invoice.new(
  #       :bill_of_lading_id => bl.id, 
  #       :invoice_date => Date.today, 
  #       :due_date => vessel.etd_date + si.shipper.credit_term.to_i,
  #       :to_shipper => si.shipper.company_name, 
  #       :vessel => si.feeder_vessel,
  #       :port_of_loading => si.port_of_loading, 
  #       :destination => si.final_destination, 
  #       :bl_no => si.master_bl_no,
  #       :ibl_no => si.si_no,
  #       :shipper_ref => si.shipper_reference, 
  #       :etd => si.vessels.first.etd_date,
  #       :eta => si.vessels.last.eta_date,
  #       :head_letter => params[:letter].upcase, 
  #       # :invoice_details_attributes => details
  #     )
  #     @invoice.no_invoice = @invoice.generate_invoice_number
  #     # (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
      
  #     items = []
  #     unless params[:iid].blank?
  #       inv = BillOfLadingInvoice.find(params[:iid])
  #       unless inv.bill_of_lading_items.blank?
  #         inv.bill_of_lading_items.each do |item|
  #           items << { description: item.description, amount: item.amount('IDR'), volume: item.volume }
  #         end
  #       end
  #     end

  #     if items.blank?
  #       (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
  #     else
  #       @invoice.invoice_details.build(items)
  #     end

  #     render :json => {'success' => true, 'message' => render_to_string(:action => "new",:layout => false)}.to_json and return
  #   else
  #     output = {
  #       'success' => false, 
  #       'message' => "Please complete SI data, Thanks. Go to <a href=\"#{ edit_shipping_instruction_path(si) }\">Update SI</a>",
  #       'errors' => array_result[1][1]
  #     }
  #     render :json => output.to_json and return
  #   end
  # end

  def create_invoice
    bl = BillOfLading.find(params[:bid])
    si = bl.shipping_instruction

    json_result = si.is_complete
    array_result = json_result.to_a

    if array_result[0][1]
      vessel = si.vessels.first

      currency = ['USD', 'IDR'].include?(params[:currency].upcase) ? params[:currency].upcase : 'IDR' 
      
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
        :currency_code => currency
      )
      @invoice.no_invoice = @invoice.generate_invoice_number
      
      items = []
      unless params[:iid].blank?
        calculate_invoice = BillOfLadingInvoice.find(params[:iid])
        currency = @invoice.currency_code
        
        @invoice.vat_10 = calculate_invoice.invoice_vat_10(currency)
        @invoice.vat_1 = calculate_invoice.invoice_vat_1(currency)
        @invoice.pph_23 = calculate_invoice.invoice_pph_23(currency)
        @invoice.rate = calculate_invoice.rate

        @invoice.default_total_amount = calculate_invoice.invoice_total_invoice(currency)
        @invoice.default_vat_10 = calculate_invoice.invoice_vat_10(currency)
        @invoice.default_vat_1 = calculate_invoice.invoice_vat_1(currency)
        @invoice.default_total_include_vat = @invoice.default_total_include_vat
        @invoice.default_pph_23 = calculate_invoice.invoice_pph_23(currency)
        @invoice.default_total_after_pph_23 = @invoice.default_total_after_pph_23
        @invoice.default_rate = calculate_invoice.rate

        calculate_invoice.bill_of_lading_items.each do |item|
          @invoice.invoice_details.build({ description: item.description, volume: item.volume.to_f, amount: item.invoice_amount(currency), default_amount: item.invoice_amount(currency) })
        end
      end

      if @invoice.invoice_details.blank?
        (3-@invoice.invoice_details.size).times { @invoice.invoice_details.build }
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

  def details
    @invoice = Invoice.find_by(:no_invoice => params[:no_invoice])
    render "details", :layout => false
  end

  def update_status
    begin
      invoice = Invoice.find(params[:id])
      invoice.status = params[:status]

      if invoice.save(validate: false)
        redirect_to invoice, notice: "Status updated" and return
      end
    rescue
        redirect_to '/list-inv-dbn', notice: "An error occured, please try again." and return
    end
  end

  def paid
    if !params[:date_of_payment].blank? && !params[:id].blank?
      invoice = Invoice.find(params[:id])
      if invoice
        invoice.status_payment = 1
        invoice.date_of_payment = params[:date_of_payment]
        invoice.notes_payment = params[:notes_payment]
        invoice.save(validate: false)

        if invoice.notes_payment.blank?
          notes_payment = "&nbsp;"
        else
          notes_payment = "<div class=\"wrap collapsed\">#{invoice.notes_payment}</div><a class=\"adjust\" href=\"#\">+ More</a>"
        end

        output = {'success' => true, 'message' => 'Update success', 'date_of_payment' => params[:date_of_payment].to_time.strftime('%d-%b-%Y'), 'notes' => notes_payment }
      else
        output = {'success' => false, 'message' => 'Invoice already closed'}
      end
    else
      output = {'success' => false, 'message' => 'Enter date of payment'}
    end
    render :json => output.to_json
  end

  def unpaid
    invoice = Invoice.find_by(id: params[:id], no_invoice: params[:no])
    if invoice
      invoice.status_payment = 0
      invoice.date_of_payment = ''
      invoice.notes_payment = ''
      invoice.save(validate: false)
      output = {'success' => true, 'message' => 'Update success'}
    elsif invoice.status == 0
      output = {'success' => false, 'message' => 'Invoice already open'}
    end
    render :json => output.to_json
  end

  def cancel
    invoice = Invoice.find(params[:id])
    if invoice
      invoice.is_cancel = 1
      if invoice.save(:validate => false)
        redirect_to invoice, notice: "#{invoice.head_letter.capitalize} has been update to cancel" and return
      end
    end
    redirect_to invoice
  end

  def uncancel
    invoice = Invoice.find(params[:id])
    if invoice
      invoice.is_cancel = 0
      if invoice.save(:validate => false)
        redirect_to invoice, notice: "#{invoice.head_letter.capitalize} has been update to uncancel" and return
      end
    end
    redirect_to invoice
  end

  # def controlCenter
  #   render "control_center"
  # end

  # def searchInvoices
  #   if ((params.has_key?(:shipper_id) && !params[:shipper_id].blank?) && params.has_key?(:date_from) && params.has_key?(:date_to))
  #     @invoices = Invoice.includes(:bill_of_lading)
  #       .where(invoice_date: params[:date_from].to_date..params[:date_to].to_date, bill_of_ladings: {shipper_id: params[:shipper_id]})
  #       .references(:bill_of_ladings)
  #   elsif (params.has_key?(:date_from) && params.has_key?(:date_to))
  #     @invoices = Invoice.where(invoice_date: params[:date_from].to_date..params[:date_to].to_date)
  #   end
    
  #   render "control_center"
  # end

  # def outstandingBonShipment
  #   render "outstanding_bon_shipment"
  # end

  # def searchBonShipment
  #   revenue = []
  #   CostRevenue.all.each do |c|
  #     c.payment_no.split(",").each do |no|
  #       revenue.push(no)
  #     end
  #   end
  #   if ((params.has_key?(:shipper_id) && !params[:shipper_id].blank?) && params.has_key?(:date_from) && params.has_key?(:date_to))
  #     @invoices = Invoice.includes(:bill_of_lading)
  #       .where(invoice_date: params[:date_from].to_date..params[:date_to].to_date, bill_of_ladings: {shipper_id: params[:shipper_id]})
  #       .references(:bill_of_ladings)
  #   elsif (params.has_key?(:date_from) && params.has_key?(:date_to))
  #     @invoices = Invoice.where(invoice_date: params[:date_from].to_date..params[:date_to].to_date)
  #   end
  #   @invoices = @invoices.includes(:payments).where("payments.payment_no IS NULL OR payments.payment_no NOT IN (?)", revenue).references(:payments)
  #   render "outstanding_bon_shipment"
  # end

  def print
    @print_title = "Invoices: " + @invoice.no_invoice
    render "_invoice", layout: 'print'
  end

  def update_tax
    if !params[:tax_issued].blank? && !params[:status_tax].blank? && !params[:id].blank?
       # && (!params[:vat_10_no].blank? || !params[:vat_1_no].blank? || !params[:pph_23_no].blank?)
      invoice = Invoice.find(params[:id])
      if invoice
        invoice.tax_issued = Date.parse(params[:tax_issued])
        invoice.vat_10_no = params[:vat_10_no]
        invoice.vat_1_no = params[:vat_1_no]
        invoice.pph_23_no = params[:pph_23_no]
        
        # invoice.vat_10 = params[:vat_10]
        # invoice.vat_1 = params[:vat_1]
        # invoice.pph_23 = params[:pph_23]

        invoice.vat_10_2 = params[:vat_10] if invoice.add_vat_10_tax == '1'
        invoice.vat_1_2 = params[:vat_1] if invoice.add_vat_1_tax == '1'
        invoice.pph_23_2 = params[:pph_23] if invoice.add_pph_23_tax == '1'

        invoice.status_tax = params[:status_tax]
        invoice.save(validate: false)

        vat_10 = invoice.is_canceled? ? "" : invoice.vat_10_tax
        vat_1 = invoice.is_canceled? ? "" : invoice.vat_1_tax
        pph_23 = invoice.is_canceled? ? "" : invoice.pph_23_tax

        output = {'success' => true, 'message' => 'Update success', 'tax_issued' => invoice.tax_issued, 'status_tax' => invoice.status_tax, 'status_tax_humanize' => invoice.status_tax.humanize, 'vat_10_no' => invoice.vat_10_no, 'vat_1_no' => invoice.vat_1_no, 'pph_23_no' => invoice.pph_23_no, 'vat_10' => vat_10, 'vat_1' => vat_1, 'pph_23' => pph_23, 'add_vat_10_tax' => invoice.add_vat_10_tax, 'add_vat_1_tax' => invoice.add_vat_1_tax, 'add_pph_23_tax' => invoice.add_pph_23_tax }
      else
        output = {'success' => false, 'message' => 'Invoice already closed'}
      end
    else
      output = {'success' => false, 'message' => 'Enter Tax Issued'}
    end
    render :json => output.to_json
  end

  def report
    @report = InvoiceReport.new(report_params)
    generate_report(@report)
  end

  private
    def validate_edit_print
        invoice = Invoice.find(params[:id])
        if invoice.status != 0 || invoice.is_cancel != 0
          redirect_to '/list-inv-dbn', notice: "Can't edit the invoice with status Closed, Printed, or Canceled" and return
        end
    end

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def load_description
      @details = InvoiceDetail.group(:description).all
      @agents = Agent.search
      @shippers = Shipper.search
      @consignees = Consignee.search
    end

    def invoice_params
      params.require(:invoice).permit(:bill_of_lading_id, :no_invoice, :invoice_date, :due_date, :currency_code, :rate, :status, :notes,
        :to_shipper, :vessel, :port_of_lading, :port_of_loading, :destination, :bl_ibl_no, :bl_no, :ibl_no, :customer, :customer_ori, :shipper_ref, :etd, :eta, :head_letter,
        :other, :vat_10, :vat_1, :pph_23,
        :add_vat_10, :add_vat_1, :add_total_include_vat, :add_pph_23, :add_total_after_pph_23, :add_rate, 
        :default_total_amount, :default_vat_10, :default_vat_1, :default_total_include_vat, :default_pph_23, :default_total_after_pph_23, :default_rate, 
        # invoice_details_attributes: [:id, :description, :amount, :volume, :_destroy])
        invoice_details_attributes: [:id, :description, :amount, :volume, :_destroy, :default_amount])
        # invoice_other_details_attributes: [:id, :description, :amount, :volume, :_destroy],
        # invoice_rate_attributes: [:id, :description, :amount, :volume, :_destroy])
    end

    def report_params
      params.require(:invoice_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], head_letters: [])
    end

    def enable_edit_invoice
      # redirect_to @invoice, notice: "#{@invoice.ibl_ref} : Invoice already Paid and C/R Complete" unless @invoice.is_editable_invoice?
      unless @invoice.is_editable_invoice?
        tmp = []
        tmp.push "Invoice already Paid" if @invoice.is_payment_closed?
        tmp.push "C/R Complete" if @invoice.shipping_instruction.is_cr_completed?
        redirect_to @invoice, notice: "#{tmp.join(" and ")}"
        return
      end
    end
end
