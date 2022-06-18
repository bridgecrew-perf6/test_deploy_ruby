class CostRevenuesController < ApplicationController
  before_filter :authorize
  before_action :is_admin, except: [:print_cover, :import_data]
  # before_action :set_cost_revenue, only: [:show, :edit, :update, :destroy, :close_cost_revenue, :print_cover]
  before_action :set_cost_revenue, only: [:show, :edit, :update, :destroy, :close_cost_revenue]
  before_action :load_data, only: [:new, :edit, :create, :update]
  before_action :load_description, only: [:new, :edit, :create, :update, :duplicate_si]
  # before_action :load_comparison, only: [:new, :edit, :create, :update]

  # GET /cost_revenues
  # GET /cost_revenues.json
  def index
    @shipping_instructions = ShippingInstruction.get_cost_revenues(params)

    @report = CostRevenueReport.new
  end

  # GET /cost_revenues/1
  # GET /cost_revenues/1.json
  def show
    respond_to do |format|
      format.html { render }
      # format.html { 
      #   @shipping_instruction = @cost_revenue.shipping_instruction
      #   render "reports/html/cost_revenue_selling_buying_report.html.erb" 
      # }
      format.pdf {
        filename = [@cost_revenue.ibl_ref,
                    @cost_revenue.final_destination].join(" - ")

        # template = params[:cover] == "true" ? "show-cover-pdf.html.erb" : "show-pdf.html.erb"
        # html = render_to_string(layout: false, action: template, formats: [:html], handler: [:erb])
        @shipping_instruction = @cost_revenue.shipping_instruction
        html = render_to_string(layout: false, action: "../reports/html/cost_revenue_selling_buying_report.html.erb", formats: [:html], handler: [:erb])
        kit = PDFKit.new(html, :orientation => 'Landscape')
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => "#{filename}.pdf", :type => 'application/pdf', :disposition => "inline")
        return # to avoid double render call
      }
    end
  end

  # GET /cost_revenues/new
  def new
    @cost_revenue = CostRevenue.initialize_new(params)
    # raise @cost_revenue.inspect
    # 8.times { @cost_revenue.cost_revenue_items.build }
    @cost_revenue.cost_revenue_items.build if @cost_revenue.cost_revenue_items.blank?
  end

  # GET /cost_revenues/1/edit
  def edit
    # (8 - @cost_revenue.cost_revenue_items.size).times { @cost_revenue.cost_revenue_items.build }
    @cost_revenue.cost_revenue_items.build if @cost_revenue.cost_revenue_items.blank?
  end

  # POST /cost_revenues
  # POST /cost_revenues.json
  def create
    @cost_revenue = CostRevenue.new(cost_revenue_params)
    # if !params[:cost_revenue][:si_no].blank?
    #   si = ShippingInstruction.find_by(si_no: params[:cost_revenue][:si_no])
    #   @cost_revenue.shipping_instruction_id = si.id
    # end
    if @cost_revenue.valid?
      respond_to do |format|
        if @cost_revenue.save
          format.html { redirect_to @cost_revenue, notice: 'Cost revenue was successfully created.' }
          format.json { render action: 'show', status: :created, location: @cost_revenue }
        else
          format.html { render action: 'new' }
          format.json { render json: @cost_revenue.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html {
          8.times { @cost_revenue.cost_revenue_items.build }
          render action: 'new'
        }
        format.json { render json: @cost_revenue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cost_revenues/1
  # PATCH/PUT /cost_revenues/1.json
  def update
    respond_to do |format|
      if @cost_revenue.update(cost_revenue_params)
        format.html { redirect_to @cost_revenue, notice: 'Cost revenue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cost_revenue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cost_revenues/1
  # DELETE /cost_revenues/1.json
  def destroy
    @cost_revenue.destroy
    respond_to do |format|
      format.html { redirect_to cost_revenues_url }
      format.json { head :no_content }
    end
  end

  def close_cost_revenue
    list_inv = @cost_revenue.payment_no.split(",")
    payments = Payment.where(payment_no: list_inv)
    payments.each do |pay|
      pay.payment_histories.each do |hist|
        hist.invoice.status = 1
        hist.invoice.save
      end
    end

    si = @cost_revenues.shipping_instruction
    si.status = 1
    si.save

    bl = @si.bill_of_lading
    bl.status = 1
    bl.save
    
    Invoice.where(shipping_instruction: si).each do |invoice|
      invoice.status = 1
      invoice.save
    end
    DebitNote.where(shipping_instruction: si).each do |invoice|
      invoice.status = 1
      invoice.save
    end
    Note.where(shipping_instruction: si).each do |invoice|
      invoice.status = 1
      invoice.save
    end
    redirect_to @cost_revenue, notice: "Shipping Instruction, Bill of Lading and Invoice status update to close"
  end

  def update_status
    begin
      cost_revenue = CostRevenue.find(params[:id])
      cost_revenue.update_status(params[:status])

      # cost_revenue.shipping_instruction.bill_of_lading.invoices.each do |inv|
      #   inv.status = params[:status]
      #   inv.save(validate: false)
      # end

      # cost_revenue.shipping_instruction.bill_of_lading.debit_notes.each do |inv|
      #   inv.status = params[:status]
      #   inv.save(validate: false)
      # end

      # cost_revenue.shipping_instruction.bill_of_lading.notes.each do |inv|
      #   inv.status = params[:status]
      #   inv.save(validate: false)
      # end

      # payments = PaymentReference.references(:payment).where(ibl_ref: cost_revenue.shipping_instruction.si_no).includes(:payment)

      # payments.each do |pay|
      #   pay.payment.status = params[:status]
      #   pay.payment.save(validate: false)
      # end

      redirect_to cost_revenue, notice: "Status updated"
    rescue => ex
      redirect_to cost_revenues_path, notice: "An error occured, please try again."
    end
  end

  def import_data
    begin      
      unless params[:ibl_ref].to_s.empty?
        shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
        services = SIServices.new(shipping_instruction)

        # render text: services.get_cost_revenues_data.to_json and return
        # render text: services.get_cost_revenue_items_data.to_json and return
        render text: services.get_cost_revenue_data.to_json and return
      else
        raise
      end
    rescue => ex
      render text: {success: false, message: "SI Not Listed"}.to_json and return
      # head 200
    end
    head 200  
  end

  def duplicate_si
    if params[:id]
      @cost_revenue = CostRevenue.find(params[:id])
      @cost_revenue.initialize_new_cost_revenue
      (8 - @cost_revenue.cost_revenue_items.size).times { @cost_revenue.cost_revenue_items.build }
      # # shadow_bl_number = @bill_of_lading.new_shadow_no
      #
      # @bill_of_lading.bl_number = @bill_of_lading.new_shadow_no
      # @bill_of_lading.is_shadow = true
    end
  end

  def load_duplicate_si
    begin
      shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      # cost_revenue = shipping_instruction.cost_revenue
      # render text: cost_revenue.id
      render text: shipping_instruction.id
    rescue => ex
      head 200
    end
  end

  def shipment_comparison_data
    begin
      data = CostRevenue.get_shipment_comparison(params[:ibl_ref])
      if data
        render json: data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def sell_comparison_data
    # unless params[:ibl_ref].to_s.empty?
    #   shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
    #   services = SIServices.new(shipping_instruction)

    #   # render text: services.get_cost_revenues_data.to_json and return
    #   render text: services.get_cost_revenue_items_data.to_json and return
    # end

    # head 200
    begin
      shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      unless shipping_instruction.blank?
        services = SIServices.new(shipping_instruction)
        render json: services.get_sell_comparison_data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def cost_comparison_data
    begin
      shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      unless shipping_instruction.blank?
        services = SIServices.new(shipping_instruction)
        render json: services.get_cost_comparison_data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def sell_comparison
  end

  def print_cover
    @shipping_instruction = ShippingInstruction.find(params[:id])
    print = false
    if current_user.administrator?
      print = true
    else
      print = true unless @shipping_instruction.is_cr_completed?
    end
    if print
      @report = CostRevenueCoverReport.new
      @report.filename = [@shipping_instruction.ibl_ref, @shipping_instruction.final_destination].join(" - ")
      @report.format = "pdf"
      generate_report(@report)
    else
      redirect_to root_url, notice: "Sorry, Restricted to access these page."
    end
    return
  end

  def report
    @report = CostRevenueReport.new(report_params)
    generate_report(@report)
  end

  def print
    begin
      @shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      unless @shipping_instruction.blank?
        # if @shipping_instruction.cost_revenue.blank?
          # @cost_revenue = CostRevenue.initialize_new(params)
        # else
          @cost_revenue = @shipping_instruction.cost_revenue
        # end
        html = render_to_string(layout: false, action: "../reports/html/cost_revenue_selling_buying_report.html.erb", formats: [:html], handler: [:erb])
        kit = PDFKit.new(html, orientation: "Landscape")
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, filename: "#{@report.filename}.pdf", type: "application/pdf", disposition: "inline")
        # render "reports/html/cost_revenue_selling_buying_report"
      else
        raise
      end
    rescue => ex
      head 200
    end
    return
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cost_revenue
    @cost_revenue = CostRevenue.find(params[:id])
  end

  def load_data
    @shippers = Shipper.search
    @consignees = Consignee.search
    @carriers = Carrier.search
    @owners = Owner.search
  end

  def load_description
    @details = CostRevenueItem.group(:description).all
  end

  def load_comparison
    @shipment_comparison_data = CostRevenue.get_shipment_comparison(params[:si_no]).to_json
    # raise @shipment_comparison_data
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cost_revenue_params
    params.require(:cost_revenue)
    .permit(:shipping_instruction_id, :notes, :status,
            :ibl_ref, :master_bl_no, :shipper_reference, :carrier, :shipper_id, :consignee_id, :trade, 
            :vessel_name, :etd_date, :port_of_loading, :port_of_discharge, :final_destination, :volume,
            # :owner, 
            :owner_id, :carrier_id,
            :selling_other, :selling_rate, :selling_vat_10, :selling_vat_1, :selling_pph_23, 
            :buying_other, :buying_rate, :buying_vat_10, :buying_vat_1, :buying_pph_23, 
            :adda, :addb, :addc,
            cr_containers_attributes: [:id, :container_id, :volum],
            cost_revenue_items_attributes: [:id, :description, :selling_usd, :selling_idr, :buying_usd, :buying_idr, :_destroy, :selling_volume, :buying_volume, :item_type, :selling_total_after_tax, :buying_total_after_tax],
            volume_items_attributes: [:id, :description, :selling_usd, :selling_idr, :buying_usd, :buying_idr, :_destroy, :selling_volume, :buying_volume, :item_type],
            shipper_items_attributes: [:id, :description, :selling_usd, :selling_idr, :buying_usd, :buying_idr, :_destroy, :selling_volume, :buying_volume, :item_type],
            carrier_items_attributes: [:id, :description, :selling_usd, :selling_idr, :buying_usd, :buying_idr, :_destroy, :selling_volume, :buying_volume, :item_type],
            active_items_attributes: [:id, :description, :selling_usd, :selling_idr, :buying_usd, :buying_idr, :_destroy, :selling_volume, :buying_volume, :item_type],
            fixed_items_attributes: [:id, :description, :selling_usd, :selling_idr, :buying_usd, :buying_idr, :selling_volume, :buying_volume, :item_type]
            )
  end

  def report_params
    params.require(:cost_revenue_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
  end
end
