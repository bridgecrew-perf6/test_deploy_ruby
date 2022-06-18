class CarriersController < ApplicationController
  before_filter :authorize
  before_action :is_admin, only: [:report]
  before_action :set_carrier, only: [:show, :edit, :update, :destroy, :charges, :update_charges, :enable]
  before_action :load_description, only: [:charges, :update_charges]

  def index
    @carriers = Carrier.with_custom_fields
    @report = CarrierReport.new
    respond_to do |format|
      format.html { render }
      format.csv { send_data @carriers.to_csv, :filename => "Carriers-" + Date.today.to_s + ".csv" }
      format.xls {
        headers["Content-Disposition"] = 'attachment; filename="Carriers-' + Date.today.to_s + '.xls"'
      }
    end
  end

  def show
  end

  def new
    @carrier = Carrier.new
  end

  def edit
  end

  def create
    @carrier = Carrier.new(carrier_params)

    if @carrier.save
      redirect_to @carrier, notice: 'Carrier was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @carrier.update(carrier_params)
      redirect_to @carrier, notice: 'Carrier was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @carrier.set_deleted
    redirect_to carriers_url, notice: 'Carrier was successfully deleted.'
  end

  def enable
    @carrier.set_enabled
    redirect_to carriers_url, notice: "Carrier was successfully enabled."
  end

  def charges
    @carrier.carrier_items.build( [
      { description: 'Doc' },
      { description: 'Adm' },
      { description: 'Seal' },
      { description: 'AMS/ENS' },
      { description: 'Telex' },
      { description: 'Switch' },
      { description: 'Certificate' },
      { description: 'SIA' }
    ]) if @carrier.carrier_items.blank?
  end

  def update_charges
    if @carrier.update(carrier_charges_params)
      # unless params[:input]
      #   redirect_to carriers_url, notice: "Charges Carrier #{@carrier.name} was successfully updated."
      # else
        redirect_to charges_carrier_path(@carrier), notice: 'Charges was successfully updated.'
      # end
    else
      render action: 'charges'
    end
  end

  def carrier_charges
    # begin
      data = Carrier.get_carrier_charges(params[:id])
      if data
        render json: data.to_json and return
      # else
      #   raise
      end
    # rescue => ex
    #   head 200
    # end
  end

  def report
    @report = CarrierReport.new(report_params)
    generate_report(@report)
  end

  private

  def set_carrier
    @carrier = Carrier.find(params[:id])
  end

  def load_description
    @details = CarrierItem.group(:description).all
  end

  def carrier_params
    params.require(:carrier).permit(:name, :credit_term, :reference, :address, :notes, custom_fields_attributes: [:id, :field_key, :field_name, :field_value, :_destroy])
  end

  def carrier_charges_params
    params.require(:carrier).permit(carrier_items_attributes: [:id, :description, :amount_usd, :amount_idr, :_destroy])
  end

  def report_params
    params.require(:carrier_report).permit(:format)
  end
end
