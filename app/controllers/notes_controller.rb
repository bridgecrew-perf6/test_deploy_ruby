class NotesController < ApplicationController
  # layout "print", :only => [ :print ]
  
  before_filter :authorize, except: [:paid, :unpaid]
  before_action :set_debit_note, only: [:show, :edit, :update, :destroy, :update_status, :cancel, :uncancel]
  before_action :validate_edit_print, only: [:edit, :update, :print]
  before_action :load_description, only: [:new, :edit, :create, :update, :create_note]

  before_action :enable_edit_invoice, only: [:edit, :update, :update_status, :cancel, :uncancel]

  # GET /debit_notes
  # GET /debit_notes.json
  def index
    @notes = Note.includes(:bill_of_lading).order("bill_of_ladings.bl_number DESC")
  end

  # GET /debit_notes/1
  # GET /debit_notes/1.json
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
    #     send_data(kit.to_pdf, :filename => @note.no_note + ".pdf", :type => 'application/pdf', :disposition  => "inline")
    #     return # to avoid double render call
    #   }
    # end
    @invoice = @note
    respond_to do |format|
      format.html { 
        render "invoices/show.html.erb"
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

  # GET /debit_notes/new
  def new
    @note = Note.new
    @note.no_note = @note.generate_note_number
    3.times { @note.invoice_details.build }
  end

  # GET /debit_Note/1/edit
  def edit    
    @note.to_shipper = @note.bill_of_lading.shipper.company_name if @note.to_shipper.nil?
    @note.vessel = @note.bill_of_lading.feeder_vessel if @note.vessel.nil?
    @note.destination = @note.bill_of_lading.final_destination if @note.destination.nil?
    @note.bl_ibl_no = [@note.bill_of_lading.master_bl_no, @note.bill_of_lading.bl_number].join(" / ") if @note.bl_ibl_no.nil?
    @note.shipper_ref = @note.bill_of_lading.shipping_instruction.shipper_reference if @note.shipper_ref.nil?
    @note.etd = @note.bill_of_lading.shipping_instruction.vessels.first.etd_date if @note.etd.nil?
    @note.eta = @note.bill_of_lading.shipping_instruction.vessels.last.eta_date if @note.eta.nil?

    unless params[:iid].blank?
      @note.invoice_details.each do |detail|
        detail._destroy = 1
      end
      
      if calculate_invoice = BillOfLadingInvoice.find_by(id: params[:iid])
        redirect_to edit_note_path(@note), notice: "Invoice #{@note.invoice_no} with #{calculate_invoice.shipping_instruction.ibl_ref} was not connected." unless calculate_invoice.shipping_instruction.ibl_ref == @note.ibl_ref
        
        currency = @note.currency_code
        
        @note.vat_10 = calculate_invoice.invoice_vat_10(currency)
        @note.vat_1 = calculate_invoice.invoice_vat_1(currency)
        @note.pph_23 = calculate_invoice.invoice_pph_23(currency)
        @note.rate = calculate_invoice.rate

        @note.default_total_amount = calculate_invoice.invoice_total_invoice(currency)
        @note.default_vat_10 = calculate_invoice.invoice_vat_10(currency)
        @note.default_vat_1 = calculate_invoice.invoice_vat_1(currency)
        @note.default_total_include_vat = @note.default_total_include_vat
        @note.default_pph_23 = calculate_invoice.invoice_pph_23(currency)
        @note.default_total_after_pph_23 = @note.default_total_after_pph_23
        @note.default_rate = calculate_invoice.rate

        calculate_invoice.bill_of_lading_items.each do |item|
          @note.invoice_details.build({ description: item.description, volume: item.volume.to_f, amount: item.invoice_amount(currency), default_amount: item.invoice_amount(currency) })
        end
      # else
      #   (3-@note.invoice_details.size).times { @note.invoice_details.build }
      end
      3.times { @note.invoice_details.build } if @note.invoice_details.map{|p| p._destroy == 0 ? 1:0 }.sum(&:to_i) == @note.invoice_details.size
    end

    if params[:layout] == "false"
      render :json => {'success' => true, 'message' => render_to_string(:action => "edit",:layout => false)}.to_json and return
    end
  end

  # POST /debit_Note
  # POST /debit_Note.json
  def create
    @note = Note.new(note_params)
    @note.status = 0

    while Note.exists? no_note: @note.no_note  do
      @note.no_note = @note.generate_note_number
    end

    respond_to do |format|
      if @note.save
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render action: 'show', status: :created, location: @note }
      else
        format.html { 
          3.times { @note.invoice_details.build }
          render action: 'new' 
        }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /debit_Note/1
  # PATCH/PUT /debit_Note/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /debit_Note/1
  # DELETE /debit_Note/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url }
      format.json { head :no_content }
    end
  end

  def update_status
    begin
      note = Note.find(params[:id])
      note.status = params[:status]

      if note.save(validate: false)
        redirect_to note, notice: "Status updated" and return
      end
    rescue
        redirect_to '/list-inv-dbn', notice: "An error occured, please try again." and return
    end
  end

  def paid
    if !params[:date_of_payment].blank? && !params[:id].blank?
      note = Note.find(params[:id])
      if note
        note.status_payment = 1
        note.date_of_payment = params[:date_of_payment]
        note.notes_payment = params[:notes_payment]
        note.save(validate: false)

        if note.notes_payment.blank?
          notes_payment = "&nbsp;"
        else
          notes_payment = "<div class=\"wrap collapsed\">#{note.notes_payment}</div><a class=\"adjust\" href=\"#\">+ More</a>"
        end

        output = {'success' => true, 'message' => 'Update success', 'date_of_payment' => params[:date_of_payment].to_time.strftime('%d-%b-%Y'), 'notes' => notes_payment }
      else
        output = {'success' => false, 'message' => 'Note already closed'}
      end
    else
      output = {'success' => false, 'message' => 'Enter date of payment'}
    end
    render :json => output.to_json
  end

  def unpaid
    note = Note.find_by(id: params[:id], no_note: params[:no])
    if note
      note.status_payment = 0
      note.date_of_payment = ''
      note.notes_payment = ''
      note.save(validate: false)
      output = {'success' => true, 'message' => 'Update success'}
    elsif note.status == 0
      output = {'success' => false, 'message' => 'Note already open'}
    end
    render :json => output.to_json
  end

  def cancel
    note = Note.find(params[:id])
    if note
      note.is_cancel = 1
      if note.save(:validate => false)
        redirect_to note, notice: "#{note.head_letter.capitalize} has been update to cancel" and return
      end
    end
    redirect_to note
  end

  def uncancel
    note = Note.find(params[:id])
    if note
      note.is_cancel = 0
      if note.save(:validate => false)
        redirect_to note, notice: "#{note.head_letter.capitalize} has been update to uncancel" and return
      end
    end
    redirect_to note
  end

  # def create_note
  #   bl = BillOfLading.find(params[:bid])
  #   si = bl.shipping_instruction

  #   # if si.is_complete?
  #   #   vessel = bl.shipping_instruction.vessels.first
  #   #   @note = Note.new(
  #   #     :bill_of_lading_id => bl.id, 
  #   #     :dbn_date => Date.today, 
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
  #   #   @note.no_dbn = @note.generate_note_number
  #   #   3.times { @note.note_details.build }

  #   #   if @note.valid?
  #   #     @note.save
  #   #     redirect_to edit_debit_note_path @note, :layout => false
  #   #   end
  #   # else
  #   #   output = {'success' => false, 'message' => "Please complete SI data, Thank you. Go to <a href=\"#{ edit_shipping_instruction_path(si) }\">Update SI</a>"}
  #   #   render :json => output.to_json and return
  #   # end

  #   json_result = si.is_complete
  #   array_result = json_result.to_a

  #   if array_result[0][1]
  #     vessel = bl.shipping_instruction.vessels.first
  #     @note = Note.new(
  #       :bill_of_lading_id => bl.id, 
  #       :note_date => Date.today, 
  #       :due_date => vessel.etd_date + si.shipper.credit_term.to_i,
  #       :to_shipper => bl.shipping_instruction.shipper.company_name, 
  #       :vessel => bl.shipping_instruction.feeder_vessel,
  #       # :port_of_lading => bl.shipping_instruction.port_of_lading, 
  #       :port_of_loading => bl.shipping_instruction.port_of_loading, 
  #       :destination => bl.shipping_instruction.final_destination, 
  #       :bl_no => bl.shipping_instruction.master_bl_no,
  #       :ibl_no => bl.shipping_instruction.si_no,
  #       :shipper_ref => bl.shipping_instruction.shipper_reference, 
  #       :etd => bl.shipping_instruction.vessels.first.etd_date,
  #       :eta => bl.shipping_instruction.vessels.last.eta_date,
  #       :head_letter => params[:letter].upcase
  #     )
  #     @note.no_note = @note.generate_note_number
  #     # 3.times { @note.invoice_details.build }

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
  #       (3-@note.invoice_details.size).times { @note.invoice_details.build }
  #     else
  #       @note.invoice_details.build(items)
  #     end

  #     # if @note.valid?
  #     #   @note.save
  #     #   redirect_to edit_debit_note_path @note, :layout => false
  #     # end
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

  def create_note
    bl = BillOfLading.find(params[:bid])
    si = bl.shipping_instruction

    json_result = si.is_complete
    array_result = json_result.to_a

    if array_result[0][1]
      vessel = si.vessels.first

      currency = ['USD', 'IDR'].include?(params[:currency].upcase) ? params[:currency].upcase : 'IDR'

      @note = Note.new(
        :bill_of_lading_id => bl.id, 
        :note_date => Date.today, 
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
      @note.no_note = @note.generate_note_number

      items = []
      unless params[:iid].blank?
        calculate_invoice = BillOfLadingInvoice.find(params[:iid])
        currency = @note.currency_code
        
        @note.vat_10 = calculate_invoice.invoice_vat_10(currency)
        @note.vat_1 = calculate_invoice.invoice_vat_1(currency)
        @note.pph_23 = calculate_invoice.invoice_pph_23(currency)
        @note.rate = calculate_invoice.rate

        @note.default_total_amount = calculate_invoice.invoice_total_invoice(currency)
        @note.default_vat_10 = calculate_invoice.invoice_vat_10(currency)
        @note.default_vat_1 = calculate_invoice.invoice_vat_1(currency)
        @note.default_total_include_vat = @note.default_total_include_vat
        @note.default_pph_23 = calculate_invoice.invoice_pph_23(currency)
        @note.default_total_after_pph_23 = @note.default_total_after_pph_23
        @note.default_rate = calculate_invoice.rate

        calculate_invoice.bill_of_lading_items.each do |item|
          @note.invoice_details.build({ description: item.description, volume: item.volume.to_f, amount: item.invoice_amount(currency), default_amount: item.invoice_amount(currency) })
        end
      end

      if @note.invoice_details.blank?
        (3-@note.invoice_details.size).times { @note.invoice_details.build }
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

  def update_tax
    if !params[:tax_issued].blank? && !params[:status_tax].blank? && !params[:id].blank?
       # && (!params[:vat_10_no].blank? || !params[:vat_1_no].blank? || !params[:pph_23_no].blank?)
      invoice = Note.find(params[:id])
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

  private
    def validate_edit_print
        note = Note.find(params[:id])
        if note.status != 0 || note.is_cancel != 0
          redirect_to '/list-inv-dbn', notice: "Can't edit the invoice with status Closed, Printed, or Canceled" and return
        end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_debit_note
      @note = Note.find(params[:id])
    end

    def load_description
      @details = NoteDetail.group(:description).all
      @agents = Agent.search
      @shippers = Shipper.search
      @consignees = Consignee.search
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def note_params
      params.require(:note).permit(:bill_of_lading_id, :no_note, :note_date, :due_date, :currency_code, :rate, :status, 
        :notes, :to_shipper, :vessel, :port_of_lading, :port_of_loading, :destination, :bl_ibl_no, :bl_no, :ibl_no, :customer, :customer_ori, :shipper_ref, :etd, :eta, :head_letter,
        :other, :vat_10, :vat_1, :pph_23,
        :add_vat_10, :add_vat_1, :add_total_include_vat, :add_pph_23, :add_total_after_pph_23, :add_rate, 
        :default_total_amount, :default_vat_10, :default_vat_1, :default_total_include_vat, :default_pph_23, :default_total_after_pph_23, :default_rate, 
        # invoice_details_attributes: [:id, :description, :amount, :volume, :_destroy],
        invoice_details_attributes: [:id, :description, :amount, :volume, :_destroy, :default_amount],
        note_details_attributes: [:id, :description, :amount, :volume, :_destroy])
    end

    def enable_edit_invoice
      @invoice = @note
      unless @invoice.is_editable_invoice?
        tmp = []
        tmp.push "Invoice already Paid" if @invoice.is_payment_closed?
        tmp.push "C/R Complete" if @invoice.shipping_instruction.is_cr_completed?
        redirect_to @invoice, notice: "#{tmp.join(" and ")}"
        return
      end
    end
end
