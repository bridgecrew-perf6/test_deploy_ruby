class BillOfLandingsController < ApplicationController
  layout "print", :only => [ :print ]

  before_filter :authorize
  before_action :set_bill_of_landing, only: [:show, :edit, :update, :destroy, :print]
  before_action :load_data, only: [:new, :edit, :create, :update, :createBL]

  def index
    if params[:SI] && params[:query]
      arr_si = params[:SI].split(",")
      shipping_instruction = ShippingInstruction.where(si_no: arr_si)
      @bill_of_landings = BillOfLanding.where(shipping_instruction_id: shipping_instruction)
    else
      @bill_of_landings = BillOfLanding.all
    end
    respond_to do |format|
      format.html 
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html { render }
      format.pdf {
        html = render_to_string(:layout => false , :action => "show-pdf.html.erb", :formats => [:html], :handler => [:erb])
        kit = PDFKit.new(html)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
        send_data(kit.to_pdf, :filename => @bill_of_landing.bl_number + ".pdf", :type => 'application/pdf', :disposition  => "inline")
        return # to avoid double render call
      }
    end
  end

  def new
    @bill_of_landing = BillOfLanding.new
  end

  def edit
  end

  def create
    @bill_of_landing = BillOfLanding.new(bill_of_landing_params)

    if @bill_of_landing.save
      redirect_to @bill_of_landing, notice: 'Bill of landing was successfully created.'
    else
      render action: 'new' 
    end
  end

  def update
    if @bill_of_landing.update(bill_of_landing_params)
      redirect_to @bill_of_landing, notice: 'Bill of landing was successfully updated.' 
    else
      render action: 'edit' 
    end
  end

  def destroy
    @bill_of_landing.destroy
    redirect_to bill_of_landings_url 
  end

  def createBL
    @si = ShippingInstruction.find(params[:sid])
    @bill_of_landing = BillOfLanding.new(:shipping_instruction_id => @si.id, :shipper_id => @si.shipper_id, :consignee_id => @si.consignee_id, 
      :notify_party => @si.notify_party, :country_of_origin => @si.country_of_origin, :place_of_receipt => @si.place_of_receipt, 
      :port_of_loading => @si.port_of_loading, :port_of_discharge => @si.port_of_discharge, :final_destination => @si.final_destination, 
      :feeder_vessel => @si.feeder_vessel, :connection_vessel => @si.connection_vessel, :marks_no => @si.marks_no, :description_packages => @si.description_packages, 
      :gw => @si.gw, :measurement => @si.measurement, :container_no => @si.container_no, :freight => @si.freight, :freight_details => @si.freight_details, 
      :no_of_obl => @si.no_of_obl, :bl_number => @si.si_no, :shipper_reference => @si.shipper_reference)
    render action: 'new'
  end

  def print
    @print_title = "Bill of Lading: " + (@bill_of_landing.bl_number.blank? ? @bill_of_landing.shipping_instruction.si_no : @bill_of_landing.bl_number)
    render "_bill_of_lading"
  end

  private

    def set_bill_of_landing
      @bill_of_landing = BillOfLanding.find(params[:id])
    end

    def load_data
      @countries = Country.all
      @shippers = Shipper.all
      @consignees = Consignee.all
    end

    def bill_of_landing_params
      params.require(:bill_of_landing).permit(:shipping_instruction_id, :shipper_id, :consignee_id, :notify_party, :country_of_origin, :also_notify_party, :place_of_receipt, :port_of_loading, :port_of_discharge, :final_destination, :feeder_vessel, :connection_vessel, :marks_no, :description_packages, :gw, :measurement, :container_no, :freight, :freight_details, :no_of_obl, :date_of_issue, :shipped_on_board, :special_clause, :create_by, :update_by, :bl_number, :place_of_issue)
    end
end
