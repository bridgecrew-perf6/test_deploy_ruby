class CarrierBanksController < ApplicationController
  before_filter :authorize
  before_action :is_admin, only: [:report]
  before_action :load_data, only: [:new, :edit, :create, :update]
  before_action :set_carrier_bank, only: [:show, :edit, :update, :destroy, :enable]

  # GET /carrier_banks
  # GET /carrier_banks.json
  def index
    # @carrier_banks = CarrierBank.search(params[:code])
    # @carrier_banks = CarrierBank.search(params)
    @carrier_banks = CarrierBank.with_custom_fields
    @report = CarrierBankReport.new
    respond_to do |format|
      format.html { render }
      # format.json { render json: @carrier_banks, :include => :carrier }
      format.json { render json: CarrierBank.search(params), :include => :carrier }
    end
  end

  # GET /carrier_banks/1
  # GET /carrier_banks/1.json
  def show
  end

  # GET /carrier_banks/new
  def new
    @carrier_bank = CarrierBank.new
  end

  # GET /carrier_banks/1/edit
  def edit
  end

  # POST /carrier_banks
  # POST /carrier_banks.json
  def create
    @carrier_bank = CarrierBank.new(carrier_bank_params)

    respond_to do |format|
      if @carrier_bank.save
        format.html { redirect_to @carrier_bank, notice: 'Carrier bank was successfully created.' }
        format.json { render action: 'show', status: :created, location: @carrier_bank }
      else
        format.html { render action: 'new' }
        format.json { render json: @carrier_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carrier_banks/1
  # PATCH/PUT /carrier_banks/1.json
  def update
    respond_to do |format|
      if @carrier_bank.update(carrier_bank_params)
        format.html { redirect_to @carrier_bank, notice: 'Carrier bank was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @carrier_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carrier_banks/1
  # DELETE /carrier_banks/1.json
  def destroy
    @carrier_bank.set_deleted
    respond_to do |format|
      format.html { redirect_to carrier_banks_url, notice: 'Carrier bank was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def enable
    @carrier_bank.set_enabled
    redirect_to carrier_banks_url, notice: "Carrier bank was successfully enabled."
  end

  def carrier_details
    @carrier_bank = CarrierBank.find(params[:cid])
    render layout: false
  end

  def report
    @report = CarrierBankReport.new(report_params)
    generate_report(@report)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_carrier_bank
    @carrier_bank = CarrierBank.find(params[:id])
  end

  def load_data
    @carriers = Carrier.with_custom_fields
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def carrier_bank_params
    params.require(:carrier_bank).permit(:carrier_id, :bank_name, :bank_address, :acc_name, :acc_no, :swift_code, :currency, :branch)
  end

  def report_params
    params.require(:carrier_bank_report).permit(:format)
  end
end
