class BillOfLadingsController < ApplicationController
  # layout "print", :only => [:print]

  before_filter :authorize
  before_action :set_bill_of_lading, only: [:show, :edit, :update, :destroy, :print]
  before_action :validate_edit_print, only: [:edit, :update, :print]
  before_action :load_data, only: [:new, :edit, :create, :update, :create_bl, :new_part_bl]

  before_action :set_shipping_instruction, only: [:calculate_invoice, :update_calculate_invoice, :view_calculate_invoice]
  before_action :load_description, only: [:calculate_invoice, :update_calculate_invoice]

  def index
    @bill_of_ladings = BillOfLading.with_filter(params)
    @report = BlReport.new

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html { render }
      format.pdf {
        validate_edit_print
        html = render_to_string(:layout => false, :action => "show-pdf.html.erb", :formats => [:html], :handler => [:erb])
        kit = PDFKit.new(html, page_size: "A4", :margin_top => "0.5cm", :margin_left => "0.5cm",
            :margin_right => "0.5cm", :margin_bottom => "0.5cm")
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => @bill_of_lading.bl_number.to_s + ".pdf", :type => 'application/pdf',
                  :disposition => "inline")
        return # to avoid double render call
      }
    end
  end

  def new
    @bill_of_lading = BillOfLading.new
  end

  def new_part_bl
    if params[:id]
      @bill_of_lading = BillOfLading.find(params[:id])
      @bill_of_lading.initialize_new_part_bl
      # # shadow_bl_number = @bill_of_lading.new_shadow_no
      #
      # @bill_of_lading.bl_number = @bill_of_lading.new_shadow_no
      # @bill_of_lading.is_shadow = true
    end
  end

  def create_part_bl
    @bill_of_lading = BillOfLading.new(part_bill_of_lading_params)

    if @bill_of_lading.create_part_bl(@current_user)
      redirect_to @bill_of_lading, notice: 'Shipping instruction was successfully created.'
    else
      redirect_to new_part_bl_bill_of_ladings_path(id: params[:id_bl])
    end
    # @bill_of_lading.create_by = @current_user.id
    # @bill_of_lading.update_by = @current_user.id
    #
    # while BillOfLading.exists? bl_number: @bill_of_lading.bl_number do
    #   shadow_bl_number = @bill_of_lading.new_shadow_no
    #   @bill_of_lading.bl_number = shadow_bl_number
    # end
    #
    # if @bill_of_lading.save
    #   redirect_to @bill_of_lading, notice: 'Shipping instruction was successfully created.'
    # else
    #   redirect_to new_part_bl_bill_of_ladings_path(id: params[:id_bl])
    # end
  end

  def load_part_bl
    begin
      bill_of_lading = BillOfLading.find_by(bl_number: params[:hbl_no])
      render text: bill_of_lading.id
    rescue => ex
      head 200
    end
  end

  def edit
    (3 - @bill_of_lading.attachments.count).times { @bill_of_lading.attachments.build }
  end

  def create
    @bill_of_lading = BillOfLading.new(bill_of_lading_params)
    @bill_of_lading.create_by = @current_user.id
    @bill_of_lading.update_by = @current_user.id

    # if !@bill_of_lading.date_of_issue.nil? && !@bill_of_lading.feeder_vessel.nil?
    #   @bill_of_lading.shipped_on_board = "#{@bill_of_lading.feeder_vessel} AT TG. PRIOK JAKARTA INDONESIA\nDATE :
    # #{@bill_of_lading.normal_date_format(@bill_of_lading.date_of_issue)}"
    # end

    if BillOfLading.exists? bl_number: @bill_of_lading.bl_number
      redirect_to bill_of_ladings_url, notice: 'Bill of lading already created' and return
    end

    if @bill_of_lading.save
      redirect_to @bill_of_lading, notice: 'Bill of lading was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @bill_of_lading.update_and_create_history(bill_of_lading_params, @current_user)
      redirect_to @bill_of_lading, notice: 'Bill of lading was successfully updated.'
    else
      render action: :calculate_invoice
    end

    # @bill_of_lading.assign_attributes(bill_of_lading_params)
    # if @bill_of_lading.valid?
    #   bl_history = BillOfLadingHistory.new
    #   bl_history.populate_data(@bill_of_lading)
    #   # if !@bill_of_lading.date_of_issue.nil? && !@bill_of_lading.feeder_vessel.nil?
    #   #   @bill_of_lading.shipped_on_board = "#{@bill_of_lading.feeder_vessel} AT TG. PRIOK JAKARTA INDONESIA\nDATE : #{@bill_of_lading.normal_date_format(@bill_of_lading.date_of_issue)}"
    #   # end
    #
    #   if @bill_of_lading.changed?
    #     @bill_of_lading.update_by = @current_user.id
    #     bl_history.save
    #   end
    # end
    # if @bill_of_lading.save
    #   redirect_to @bill_of_lading, notice: 'Bill of lading was successfully updated.'
    # else
    #   render action: 'edit'
    # end
  end

  def destroy
    @bill_of_lading.destroy
    redirect_to bill_of_ladings_url
  end

  def history
    @bill_of_lading = BillOfLadingHistory.find(params[:id])
    respond_to do |format|
      format.pdf {
        html = render_to_string(:layout => false, :action => "show-pdf.html.erb", :formats => [:html], :handler => [:erb])
        kit = PDFKit.new(html)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => @bill_of_lading.bl_number + ".pdf", :type => 'application/pdf', :disposition => "inline")
        return # to avoid double render call
      }
    end
  end

  def create_bl
    @bill_of_lading = BillOfLading.new
    @bill_of_lading.initialize_new(params[:sid])

    # if @si.freight.include? ("LCL - LCL")
    #   @bill_of_lading.description_packages = ""
    # else
    #   @bill_of_lading.description_packages = "SHIPPER'S LOAD, STOW AND COUNT"
    # end

    (3 - @bill_of_lading.attachments.count).times { @bill_of_lading.attachments.build }

    render action: 'new'
  end

  def print
    @print_title = "Bill of Lading: " + (@bill_of_lading.bl_number.blank? ?
      @bill_of_lading.shipping_instruction.si_no : @bill_of_lading.bl_number)
    render "_bill_of_lading", layout: 'print'
  end

  def cancel
    @bill_of_lading = BillOfLading.find(params[:id])

    if @bill_of_lading
      bl_services = BLServices.new(@bill_of_lading)
      bl_services.cancel!

      redirect_to bill_of_ladings_path, notice: "Bill of Lading has been update to cancel" and return
    end

    redirect_to bill_of_ladings_path
  end

  def uncancel
    @bill_of_lading = BillOfLading.find(params[:id])

    if @bill_of_lading
      bl_services = BLServices.new(@bill_of_lading)
      bl_services.uncancel!

      redirect_to bill_of_ladings_path, notice: "Bill of Lading has been update to uncancel" and return
    end

    redirect_to bill_of_ladings_path
  end

  def calculate_invoice
    # # raise @bill_of_lading.bill_of_lading_invoice.inspect
    # @invoice = BillOfLadingInvoice.where(bill_of_lading: @bill_of_lading).first_or_initialize
    
    # bl_count = @invoice.bill_of_lading_items.count
    # cr_count = @bill_of_lading.shipping_instruction.cost_revenue.blank? ? 0 : @bill_of_lading.shipping_instruction.cost_revenue.cost_revenue_items.count
    # @cost_revenue = @bill_of_lading.shipping_instruction.cost_revenue
    # # @bill_of_lading.bill_of_lading_items.build( [
    # #   { description: 'PEB' },
    # #   { description: 'Fiat PEB' },
    # #   { description: 'COO' },
    # #   { description: 'Trucking' },
    # #   { description: 'Fumigation' }
    # # ])
    # count = 3 - ( bl_count > cr_count ? bl_count : cr_count )
    # # count.times { @bill_of_lading.bill_of_lading_items.build }
    # count.times { @invoice.bill_of_lading_items.build }



    # @shipping_instruction = ShippingInstruction.find(params[:sid])

    # @shipping_instruction.build_bill_of_lading_invoice if @shipping_instruction.bill_of_lading_invoice.blank?
    # @cost_revenue = @shipping_instruction.cost_revenue
     
    # bl_count = @shipping_instruction.bill_of_lading_invoice.bill_of_lading_items.count
    # cr_count = @shipping_instruction.cost_revenue.blank? ? 0 : @shipping_instruction.cost_revenue.cost_revenue_items.count
    # count = 3 - ( bl_count > cr_count ? bl_count : cr_count )    
    
    # count.times { @shipping_instruction.bill_of_lading_invoice.bill_of_lading_items.build }    

    # @shipping_instruction.initialize_new_bill_of_lading_invoice
    # # raise @shipping_instruction.bill_of_lading_invoice.carrier_items.inspect
    @calculate_invoice = CalculateInvoice.find(@shipping_instruction.id)
    @calculate_invoice.initialize_new_bill_of_lading_invoice
  end

  def update_calculate_invoice
    # @invoice = BillOfLadingInvoice.where(bill_of_lading: @bill_of_lading).first_or_create

    # if @invoice.update(invoice_bill_of_lading_params)
    #   redirect_to bill_of_ladings_url, notice: 'Calculate Invoice was successfully updated.'
    # else
    #   render action: 'calculate_invoice'
    # end
    # @shipping_instruction = ShippingInstruction.find(params[:sid])
    # if @shipping_instruction.update(invoice_bill_of_lading_params)
    # # if @shipping_instruction.valid? 
    #   # @shipping_instruction.update(invoice_bill_of_lading_params)
    #   # redirect_to bill_of_ladings_url, notice: 'Calculate Invoice was successfully updated.'
    #   redirect_to calculate_invoice_bill_of_ladings_url(sid: @shipping_instruction.id), notice: 'Calculate Invoice was successfully updated.'
    # else
    #   render action: 'calculate_invoice'
    # end
    


    # @shipping_instruction = ShippingInstruction.find(params[:sid])
    # # if @shipping_instruction.bill_of_lading_invoices.map{|p| (p.rate.to_f == 0 && p._destroy != 1) ? 1:0}.sum(&:to_i) == 0
    
    # valid_rate = true    
    # invoice_bill_of_lading_params[:bill_of_lading_invoices_attributes].each do |key,value|
    #   if valid_rate && value[:rate].to_f == 0 && value[:_destroy] != '1'
    #     valid_rate = false
    #   end
    # end
    # if valid_rate
    #   @shipping_instruction.update(invoice_bill_of_lading_params)
    #   redirect_to calculate_invoice_bill_of_ladings_url(sid: @shipping_instruction.id), notice: 'Calculate Invoice was successfully updated.'
    # else
    #   # flash[:alert] = "Please fill all rate. Thanks"
    #   @shipping_instruction.attributes = invoice_bill_of_lading_params
    #   @shipping_instruction.errors.add(:base, "Please fill all rate. Thanks")
    #   @cost_revenue = @shipping_instruction.cost_revenue
    #   render action: 'calculate_invoice'
    # end

    # @shipping_instruction.attributes = invoice_bill_of_lading_params
    @calculate_invoice = CalculateInvoice.find(@shipping_instruction.id)
    @calculate_invoice.attributes = invoice_bill_of_lading_params
    if @calculate_invoice.valid?
      @calculate_invoice.save
      redirect_to calculate_invoice_bill_of_ladings_url(sid: @calculate_invoice.id), notice: 'Calculate Invoice was successfully updated.'
    else
      render action: 'calculate_invoice'
    end
  end

  def view_calculate_invoice
    @bill_of_lading_invoices = @shipping_instruction.bill_of_lading_invoices
  end

  def not_yet
    @bill_of_lading = BillOfLading.find(params[:id])

    if @bill_of_lading
      bl_services = BLServices.new(@bill_of_lading)
      bl_services.not_yet!

      redirect_to bill_of_ladings_path, notice: "Delivery Doc Bill of Lading has been update to not yet" and return
    end

    redirect_to bill_of_ladings_path
  end

  def done
    @bill_of_lading = BillOfLading.find(params[:id])

    if @bill_of_lading
      bl_services = BLServices.new(@bill_of_lading)
      bl_services.done!

      redirect_to bill_of_ladings_path, notice: "Delivery Doc Bill of Lading has been update to done" and return
    end

    redirect_to bill_of_ladings_path
  end

  def update_delivery_doc
    begin
      bill_of_lading = BillOfLading.find(params[:bl_id])
      unless bill_of_lading.blank?
        services = BLServices.new(bill_of_lading)
        if params[:status] == "Done"
          services.done!
        elsif params[:status] == "Not Yet"
          services.not_yet!
        end
        data = {success: true, ibl_ref: bill_of_lading.bl_number, status: bill_of_lading.delivery_doc_status}
        render json: data.to_json and return
      else
        raise
      end
      # raise @bill_of_lading.inspect
      # raise params.inspect
        # @bill_of_lading.update_attributes(delivery_doc: params[:status])
      # data = Array.new
      # data.push(status_delivery_doc: @bill_of_lading.status_delivery_doc)
      # data.push(ibl_ref: @bill_of_lading.bl_no)
      # raise data.to_json.inspect
      # render text: data.to_json and return
      # data = {success: true, ibl_ref: @bill_of_lading.bl_no, status_delivery_doc: @bill_of_lading.status_delivery_doc}
      # # raise data.inspect
      # if data
      #   render json: data.to_json and return
      # else
      #   raise
      # end
    rescue => ex
      head 200
    end
  end

  def import_data
    unless params[:ibl_ref].to_s.empty?
      bill_of_lading = BillOfLading.find_by(bl_number: params[:ibl_ref])
      # raise bill_of_lading.inspect
      services = BLServices.new(bill_of_lading)

      render json: services.get_invoice_data(params[:currency]).to_json and return
    end

    head 200
  end

  def report
    @report = BlReport.new(report_params)
    generate_report(@report)
  end

  private
  def validate_edit_print
    bl = BillOfLading.find(params[:id])
    unless bl.is_cancel == 0
      redirect_to bill_of_ladings_path, notice: "Can't edit the Bill of Lading with status Closed, Printed, or Canceled"
    end
  end

  def set_bill_of_lading
    @bill_of_lading = BillOfLading.find(params[:id])
  end

  def load_data
    @countries = Country.all
    @shippers = Shipper.search
    @consignees = Consignee.search
    @agents = Agent.search
  end

  def set_shipping_instruction
    @shipping_instruction = ShippingInstruction.find(params[:sid])
    @cost_revenue = @shipping_instruction.cost_revenue
  end

  def load_description
    @details = CostRevenueItem.group(:description).all
  end

  def bill_of_lading_params
    params.require(:bill_of_lading)
    .permit(:shipping_instruction_id, :shipper_id, :consignee_id, :shipper_name, :consignee_name, :notify_party,
            :country_of_origin, :also_notify_party, :agent_id, :agent_name, :is_shadow, :shipper_reference,
            :master_bl_no, :place_of_receipt, :port_of_loading, :port_of_discharge, :final_destination,
            :feeder_vessel, :connection_vessel, :marks_no, :description_packages, :gw, :measurement, :container_no,
            :freight, :freight_details, :no_of_obl, :date_of_issue, :shipped_on_board, :special_clause, :create_by,
            :update_by, :bl_number, :place_of_issue, :hide_agent,
            attachments_attributes: [:id, :name, :asset, :_destroy]
    )
  end

  def part_bill_of_lading_params
    params.require(:bill_of_lading)
    .permit(:shipping_instruction_id, :shipper_id, :consignee_id, :shipper_name, :consignee_name, :notify_party,
            :country_of_origin, :also_notify_party, :agent_id, :agent_name, :is_shadow, :shipper_reference,
            :master_bl_no, :place_of_receipt, :port_of_loading, :port_of_discharge, :final_destination,
            :feeder_vessel, :connection_vessel, :marks_no, :description_packages, :gw, :measurement, :container_no,
            :freight, :freight_details, :no_of_obl, :date_of_issue, :shipped_on_board, :special_clause, :create_by,
            :update_by, :bl_number, :place_of_issue, :hide_agent,
            attachments_attributes: [:name, :asset, :_destroy]
    )
  end

  def invoice_bill_of_lading_params
    # params.require(:bill_of_lading_invoice)
    # .permit(:is_tick_all, :is_al, :is_gl,
    #         bill_of_lading_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy]
    # )
    # params.require(:bill_of_lading)
    # .permit(bill_of_lading_invoice_attributes: [:id, :is_tick_all, :is_al, :is_gl,
    #         bill_of_lading_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_pph_23, :_destroy]
    #         ]
    # )
    # params.require(:shipping_instruction)
    params.require(:calculate_invoice)
    .permit(bill_of_lading_invoices_attributes: [:id, :is_tick_all, :is_ai, :is_gi, :_destroy,
            :other, :rate, :vat_10, :vat_1, :pph_23, 
            bill_of_lading_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_vat_11, :add_vat_1_1, :add_pph_23, :_destroy, :item_type],
            volume_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_vat_11, :add_vat_1_1, :add_pph_23, :_destroy, :item_type],
            shipper_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_vat_11, :add_vat_1_1, :add_pph_23, :_destroy, :item_type],
            carrier_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_vat_11, :add_vat_1_1, :add_pph_23, :_destroy, :item_type],
            active_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :add_vat_10, :add_vat_1, :add_vat_11, :add_vat_1_1, :add_pph_23, :_destroy, :item_type],
            fixed_items_attributes: [:id, :description, :volume, :amount_usd, :amount_idr, :item_type]
            ]
    )
  end

  def report_params
    params.require(:bl_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
  end
end
