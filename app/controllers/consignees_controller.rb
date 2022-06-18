class ConsigneesController < ApplicationController
  before_filter :authorize
  before_action :is_admin, only: [:report]
  before_action :set_consignee, only: [:show, :edit, :update, :destroy, :enable]
  before_action :load_countries, only: [:new, :edit, :create, :update]

  def index
    @consignees = Consignee.with_custom_fields
    @report = ConsigneeReport.new
  end

  def show
  end

  def new
    @consignee = Consignee.new
  end

  def edit
  end

  def create
    @consignee = Consignee.new(consignee_params)
    
    # if consignee_params[:contact_name]
    #   @country = Country.find_by(:name => consignee_params[:country_name]);
    #   @consignee.country_id = @country.id
    # end

    if @consignee.save
      redirect_to @consignee, notice: 'Consignee was successfully created.' 
    else
      render action: 'new' 
    end
  end

  def update
    # @country = Country.find_by(:name => consignee_params[:country_name]);
    # @consignee.country_id = @country.id
    
    if @consignee.update(consignee_params)
      redirect_to @consignee, notice: 'Consignee was successfully updated.' 
    else
      render action: 'edit' 
    end
  end

  def destroy
    @consignee.set_deleted
    redirect_to consignees_url, notice: 'Consignee was successfully deleted.'  
  end

  def enable
    @consignee.set_enabled
    redirect_to consignees_url, notice: "Consignee was successfully enabled."
  end

  def report
    @report = ConsigneeReport.new(report_params)
    generate_report(@report)
  end

  private

  def set_consignee
    @consignee = Consignee.find(params[:id])
  end

  def load_countries
    @countries = Country.all
  end

  def consignee_params
    params.require(:consignee).permit(:company_name, :address, :city, :zipcode, 
      :country_id, :country_name, :contact_name, :phone, :cellphone, :email_address, 
      :custom_field1, :custom_field2, :custom_field3, :reference, :credit_term,
      custom_fields_attributes: [:id, :field_key, :field_name, :field_value, :_destroy])
  end


  def report_params
    params.require(:consignee_report).permit(:format)
  end
end
