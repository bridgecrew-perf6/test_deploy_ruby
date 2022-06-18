class PaymentInquiriesController < ApplicationController
  before_filter :authorize
	
  def index
    @payments = Payment.with_filter(params)
    @report = PaymentInquiryReport.new
    render "payments/index"
  end

  def update_status
    begin
      payment = Payment.find(params[:inquiry_id])
      payment_services = PaymentServices.new(payment)

      if payment_services.update_status!(params[:status])
        redirect_to payment, notice: "Status updated"
      end
    rescue
      redirect_to payment_inquiries_path, notice: "An error occurred, please try again."
    end
  end

	def report
		@report = PaymentInquiryReport.new(report_params)
    generate_report(@report)
	end

	private
	def report_params
		params.require(:payment_inquiry_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], row_ref_ids: [])
	end
end
