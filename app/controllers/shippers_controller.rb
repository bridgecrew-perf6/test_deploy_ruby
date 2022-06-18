class ShippersController < ApplicationController
	before_filter :authorize
  before_action :is_admin, only: [:report]
	before_action :set_shipper, only: [:show, :edit, :update, :destroy, :charges, :update_charges, :enable]
	before_action :load_countries, only: [:new, :edit, :create, :update]
  before_action :load_description, only: [:charges, :update_charges]

	def index
		@shippers = Shipper.with_custom_fields
	    @report = ShipperReport.new
			respond_to do |format|
	      format.html { render }
	      format.csv { send_data @shippers.to_csv, :filename => "Shippers-" + Date.today.to_s + ".csv" }
	      format.xls {
	        headers["Content-Disposition"] = 'attachment; filename="Shippers-' + Date.today.to_s + '.xls"'
	      }
	    end
	end

	def show
	end

	def new
		@shipper = Shipper.new
	end

	def edit
	end

	def create
		@shipper = Shipper.new(shipper_params)

		if @shipper.save
			redirect_to @shipper, notice: 'Shipper was successfully created.' 
		else
			render action: 'new' 
		end
	end

	def update
		if @shipper.update(shipper_params)
			redirect_to @shipper, notice: 'Shipper was successfully updated.'
		else
			 render action: 'edit'
		 end
	 end

	def destroy
		@shipper.set_deleted
		redirect_to shippers_url, notice: 'Shipper was successfully deleted.' 
	end

  def enable
    @shipper.set_enabled
    redirect_to shippers_url, notice: "Shipper was successfully enabled."
  end

	def charges
		@shipper.shipper_items.build( [
      { description: 'PEB' },
      { description: 'Fiat PEB' },
      { description: 'COO' },
      { description: 'Trucking' },
      { description: 'Fumigation' }
    ]) if @shipper.shipper_items.blank?
	end

	def update_charges
    if @shipper.update(shipper_charges_params)
      # unless params[:input]
	     #  redirect_to shippers_url, notice: "Charges Shipper #{@shipper.company_name} was successfully updated."
      # else
        redirect_to charges_shipper_path(@shipper), notice: 'Charges was successfully updated.'
      # end
    else
      render action: 'charges'
    end
  end

  def shipper_charges
    begin
      data = Shipper.get_shipper_charges(params[:id])
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
    @report = ShipperReport.new(report_params)
    generate_report(@report)
  end

	private

	def set_shipper
		@shipper = Shipper.find(params[:id])
	end

	def load_countries
		@countries = Country.all
	end

	def load_description
    @details = ShipperItem.group(:description).all
  end

	def shipper_params
		params.require(:shipper).permit(:company_name, :reference, :credit_term, :bl_address, :notes, 
			custom_fields_attributes: [:id, :field_key, :field_name, :field_value, :_destroy])
	end

	def shipper_charges_params
    params.require(:shipper).permit(shipper_items_attributes: [:id, :description, :amount_usd, :amount_idr, :_destroy])
  end

  def report_params
    params.require(:shipper_report).permit(:format)
  end
end
