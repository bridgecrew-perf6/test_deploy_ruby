class ShipmentTrackingsController < ApplicationController
  before_filter :authorize, only: [:index, :edit]

  def index
    @shipments = ShipmentTracking.with_filter(params)
    @report = StReport.new
  end

  def edit
    @shipment = ShipmentTracking.edit_row(params[:id])
    @shipping_instruction = @shipment.shipping_instruction
  end

  def ft_email
  	@shipment = ShipmentTracking.includes(:shipping_instruction)
  		.references(:shipping_instruction).where(id: params[:id]).first
  end

  def etd_email
  	@actual = ActualVessel.get_row(params[:id])
  end

  def eta_email
  	@actual = ActualVessel.get_row(params[:id])
  end

  def update_shipment
  	shipment = ShipmentTracking.find(params[:id])
  	if shipment.update_attributes(shipment_params)
  		render text: "" and return
  	end
  	head 200
  end

  def update_actual_shipment
  	actual_vessel = ActualVessel.find(params[:id])
  	if actual_vessel.update_attributes(actual_shipment_params)
  		render text: "" and return
  	end
  	head 200
  end

  def report
    @report = StReport.new(report_params)
    generate_report(@report)
  end

  private
  	def shipment_params
  		params.require(:shipment_tracking).permit(:fu_date, :notes, :free_request, :free_approval, :free_status)
  	end

  	def actual_shipment_params
  		params.require(:actual_vessel).permit(:actual_etd_date, :status_etd, :reason_etd, :actual_eta_date, :status_eta, :reason_eta)
  	end

  def report_params
    params.require(:st_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [])
  end
end
