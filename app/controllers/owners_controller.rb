class OwnersController < ApplicationController
  before_filter :authorize
  before_action :is_admin, only: [:report]
  before_action :set_owner, only: [:show, :edit, :update, :destroy, :enable]

  # GET /owners
  # GET /owners.json
  def index
    @owners = Owner.with_custom_fields
    @report = OwnerReport.new
  end

  # GET /owners/1
  # GET /owners/1.json
  def show
  end

  # GET /owners/new
  def new
    @owner = Owner.new
  end

  # GET /owners/1/edit
  def edit
  end

  # POST /owners
  # POST /owners.json
  def create
    @owner = Owner.new(owner_params)

    respond_to do |format|
      if @owner.save
        format.html { redirect_to @owner, notice: 'Owner was successfully created.' }
        format.json { render action: 'show', status: :created, location: @owner }
      else
        format.html { render action: 'new' }
        format.json { render json: @owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /owners/1
  # PATCH/PUT /owners/1.json
  def update
    respond_to do |format|
      if @owner.update(owner_params)
        format.html { redirect_to @owner, notice: 'Owner was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /owners/1
  # DELETE /owners/1.json
  def destroy
    @owner.set_deleted
    respond_to do |format|
      format.html { redirect_to owners_url, notice: "Owner was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def enable
    @owner.set_enabled
    redirect_to owners_url, notice: "Owner was successfully enabled."
  end

  def report
    @report = OwnerReport.new(report_params)
    generate_report(@report)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_owner
    @owner = Owner.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def owner_params
    params.require(:owner).permit(:name, :reference, :notes,
                                  custom_fields_attributes: [:id, :field_key, :field_name, :field_value, :_destroy])
  end

  def report_params
    params.require(:owner_report).permit(:format)
  end
end
