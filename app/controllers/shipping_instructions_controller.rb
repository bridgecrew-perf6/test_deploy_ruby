class ShippingInstructionsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  # layout "print", :only => [:print]

  before_filter :authorize
  before_action :set_shipping_instruction, only: [:show, :edit, :update, :destroy, :print, :cancel, :uncancel, :email]
  before_action :validate_edit_print, only: [:edit, :update, :print]
  before_action :load_data, only: [:new, :edit, :create, :update, :new_add_si, :duplicate_si]

  def index
    respond_to do |format|
      format.html {
        @shipping_instructions = ShippingInstruction.with_filter(params)
        @report = SiReport.new
        render
      }
      format.json {
        if params[:query] && params[:status]
          @shipping_instructions = ShippingInstruction.includes(:bill_of_lading)
          .where("si_no LIKE ? AND status = ? AND bill_of_ladings.id IS NOT NULL", "%#{params[:query]}%",
                 params[:status]).references(:bill_of_lading)
        end
        render json: @shipping_instructions, only: [:id, :si_no]
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        render
      }
      format.pdf {
        validate_edit_print
        html = render_to_string(:layout => false, :action => "show-pdf.html.erb", :formats => [:html], :handler => [:erb])
        kit = PDFKit.new(html, :page_size => "A4", :margin_top => "0.25cm", :margin_left => "0.25cm",
                         :margin_right => "0.25cm", :margin_bottom => "1cm")
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => @shipping_instruction.si_no + ".pdf", :type => 'application/pdf', :disposition => "inline")
        return # to avoid double render call
      }
    end
  end

  def new
    @shipping_instruction = ShippingInstruction.new(create_by: @current_user.id, update_by: @current_user.id)
    @shipping_instruction.initialize_new_si(params[:year])

    1.times { @shipping_instruction.vessels.build }
    6.times { @shipping_instruction.si_containers.build }
    (3 - @shipping_instruction.attachments.count).times { @shipping_instruction.attachments.build }
    # @shipping_instruction.save

    # redirect_to edit_shipping_instruction_path @shipping_instruction
  end

  def new_add_si
    if params[:id]
      @shipping_instruction = ShippingInstruction.find(params[:id])
      @shipping_instruction.initialize_add_si

      1.times { @shipping_instruction.vessels.build }
      6.times { @shipping_instruction.si_containers.build }
      (3 - @shipping_instruction.attachments.count).times { @shipping_instruction.attachments.build }
    end
  end

  def create_add_si
    @shipping_instruction = ShippingInstruction.new(add_shipping_inst_params)

    if @shipping_instruction.create_additional_si(@current_user)
      redirect_to @shipping_instruction, notice: 'Shipping instruction was successfully created.'
    else
      redirect_to new_add_si_shipping_instructions_path(id: params[:id_si])
    end
  end

  def load_add_si
    begin
      shipping_instruction = ShippingInstruction.find_by(si_no: params[:si_no])
      render text: shipping_instruction.id
    rescue => ex
      head 200
    end
  end

  def edit
    @shipping_instruction.change_date_format

    1.times { @shipping_instruction.vessels.build }
    6.times { @shipping_instruction.si_containers.build }
    (3 - @shipping_instruction.attachments.count).times { @shipping_instruction.attachments.build }
  end

  def create
    @shipping_instruction = ShippingInstruction.new(shipping_instruction_params)

    if @shipping_instruction.create_original(@current_user, params[:year])
      redirect_to @shipping_instruction, notice: 'Shipping instruction was successfully created.'
    else
      render action: 'new'
    end
  end

  def print
    @print_title = "Shipping Instruction: " + @shipping_instruction.si_no
    @logo_path = "/assets/logo.jpg"
    render "_shipping_instruction", layout: 'print'
  end

  def history
    @shipping_instruction = ShippingInstructionHistory.find(params[:id])
    respond_to do |format|
      format.pdf {
        html = render_to_string(:layout => false, :action => "show-pdf.html.erb", :formats => [:html], :handler => [:erb])
        kit = PDFKit.new(html)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => @shipping_instruction.si_no + ".pdf", :type => 'application/pdf', :disposition => "inline")
        return # to avoid double render call
      }
    end
  end

  def update
    if @shipping_instruction.update_and_create_history(shipping_instruction_params, @current_user)
      redirect_to @shipping_instruction, notice: 'Shipping instruction was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def cancel
    if @shipping_instruction
      si_services = SIServices.new(@shipping_instruction)
      si_services.cancel!

      redirect_to shipping_instructions_path, notice: "Shipping Instruction has been update to cancel" and return
    end

    redirect_to shipping_instructions_path
  end

  def uncancel
    if @shipping_instruction
      si_services = SIServices.new(@shipping_instruction)
      si_services.uncancel!

      redirect_to shipping_instructions_path, notice: "Shipping Instruction has been update to uncancel" and return
    end

    redirect_to shipping_instructions_path
  end

  def destroy
    @shipping_instruction.destroy
    redirect_to shipping_instructions_url
  end

  def load_data_si
    # begin
    # shipping_instruction = ShippingInstruction.references(:shipper, :vessels, {si_containers: [:container]})
    # .where(si_no: params[:query]).includes(:shipper, :vessels, {si_containers: [:container]}).first
    #
    # volume = []
    # shipping_instruction.si_containers.each do |c|
    #   if c.container.container_type == "LCL"
    #     volume.push("#{number_with_precision(c.volum, precision: 3, delimiter: ',')} M3 #{c.container.container_type}")
    #   else
    #     volume.push(c.volum.to_s + "x" + c.container.container_type)
    #   end
    # end
    #
    # payment = []
    # payments = PaymentReference.references(:payment).where(ibl_ref: shipping_instruction.si_no)
    #   .includes(:payment)
    # payments.each do |p|
    #   unless payment.include?(p.payment.payment_no)
    #     payment.push(p.payment.payment_no)
    #   end
    # end
    # payments = Payment.includes(:payment_references).where(payment_references: {ibl_ref: shipping_instruction.si_no}).references(:payment_references)
    # payments.each do |p|
    #   payment.push(p.payment_no)
    # end
    #
    # output = {
    #     :id => shipping_instruction.id,
    #     :si_no => shipping_instruction.si_no,
    #     :master_bl_no => shipping_instruction.master_bl_no,
    #     :shipper_reference => shipping_instruction.shipper_reference,
    #     :shipper => shipping_instruction.shipper.company_name,
    #     :vessel_name => shipping_instruction.vessels.first.vessel_name,
    #     :etd_date => shipping_instruction.vessels.first.etd_date.to_time.strftime('%d %B %Y'),
    #     :port_of_loading => shipping_instruction.port_of_loading,
    #     :final_destination => shipping_instruction.final_destination,
    #     :volume => volume.join(' & '),
    #     :payment => payment.join("\n"),
    #     :link_to => shipping_instruction_path(shipping_instruction.id)
    # }

    # render json: output.to_json
    # rescue => ex
    #   head 200
    # end
  end

  def booking_no
    begin
      data = ShippingInstruction.get_booking_no(params[:ibl])
      if data
        render json: data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  # def update_shipment
  #   shipping_instructions = ShippingInstruction.where(is_shadow: false)
  #   shipping_instructions.each do |si|
  #     ShipmentTracking.find_or_create_by(shipping_instruction: si)
  #   end
  #   redirect_to shipping_instructions_path
  # end

  def events
    response.headers["Content-Type"] = "text/event-stream"
    response.stream.write "update"
  ensure
    response.stream.close
  end

  # Revisi 1 Dec 2015
  def duplicate_si
    @shipping_instruction = ShippingInstruction.new(create_by: @current_user.id, update_by: @current_user.id)
    @shipping_instruction.initialize_new_si(params[:year])
    @shipping_instruction.duplicate_data(ShippingInstruction.find_by(si_no: params[:no_si]))
    
    (1 - @shipping_instruction.vessels.count).times { @shipping_instruction.vessels.build }
    (6 - @shipping_instruction.si_containers.count).times { @shipping_instruction.si_containers.build }
    (3 - @shipping_instruction.attachments.count).times { @shipping_instruction.attachments.build }
    # @shipping_instruction.save

    render action: 'new'
    # redirect_to edit_shipping_instruction_path @shipping_instruction
  end

  def import_data
    unless params[:ibl_ref].to_s.empty?
      shipping_instruction = ShippingInstruction.find_by(si_no: params[:ibl_ref])
      services = SIServices.new(shipping_instruction)

      render text: services.get_shipping_instruction_data.to_json and return
    end

    head 200
  end

  def master_bl_no
    begin
      data = ShippingInstruction.get_master_bl_no(params[:ibl])
      if data
        render json: data.to_json and return
      else
        raise
      end
    rescue => ex
      head 200
    end
  end

  def report
    @report = SiReport.new(report_params)
    generate_report(@report)
  end

  def email
    redirect_to shipping_instructions_path, notice: "Can't email the Shipping Instruction with CR status Completed" if @shipping_instruction.is_cr_completed?
  end

  private
  def validate_edit_print
    si = ShippingInstruction.find(params[:id])
    if si.status != 0 || si.is_cancel != 0
      redirect_to shipping_instructions_path, notice: "Can't edit the Shipping Instruction with status Closed, Printed, or Canceled"
    end
  end

  def set_shipping_instruction
    @shipping_instruction = ShippingInstruction.find(params[:id])
  end

  def load_data
    @countries = Country.all
    @shippers = Shipper.search
    @consignees = Consignee.search
    @carriers = Carrier.search
  end

  def shipping_instruction_params
    params.require(:shipping_instruction)
    .permit(:si_no, :shipper_id, :consignee_id, :carrier_id, :shipper_reference, :shipper_name, :consignee_name, :notify_party,
            :country_of_origin, :carrier, :pic, :feeder_vessel, :master_bl_no, :connection_vessel, :etd_jkt,
            :etd_sin, :eta, :volume, :container_id, :place_of_receipt, :port_of_loading, :port_of_transhipment,
            :port_of_discharge, :final_destination, :no_of_obl, :si_date, :marks_no, :description_packages, :gw, :nw,
            :measurement, :dimension, :freight, :freight_details, :is_shadow, :special_instructions, :container_no,
            :container_no_2, :peb_no, :inst_date, :kpbc, :hs_code, :create_by, :update_by, :order_type, :booking_no,
            # Revisi 1 Dec 2015
            :trade, :handle_by,
            # end
            order_type_details: [],
            vessels_attributes: [:id, :vessel_name, :etd_no, :etd_date, :eta_no, :eta_date, :_destroy],
            si_containers_attributes: [:id, :container_id, :volum],
            attachments_attributes: [:id, :name, :asset, :_destroy]
    )
  end

  def add_shipping_inst_params
    params.require(:shipping_instruction)
    .permit(:si_no, :shipper_id, :consignee_id, :shipper_reference, :shipper_name, :consignee_name, :notify_party,
            :country_of_origin, :carrier, :pic, :feeder_vessel, :master_bl_no, :connection_vessel, :etd_jkt,
            :etd_sin, :eta, :volume, :container_id, :place_of_receipt, :port_of_loading, :port_of_transhipment,
            :port_of_discharge, :final_destination, :no_of_obl, :si_date, :marks_no, :description_packages, :gw, :nw,
            :measurement, :dimension, :freight, :freight_details, :is_shadow, :special_instructions, :container_no,
            :container_no_2, :peb_no, :inst_date, :kpbc, :hs_code, :create_by, :update_by, :order_type, :booking_no,
            # Revisi 1 Dec 2015
            :trade, :handle_by,
            # end
            order_type_details: [],
            vessels_attributes: [:vessel_name, :etd_no, :etd_date, :eta_no, :eta_date, :_destroy],
            si_containers_attributes: [:container_id, :volum],
            attachments_attributes: [:name, :asset, :_destroy]
    )
  end

  def report_params
    params.require(:si_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
  end
end