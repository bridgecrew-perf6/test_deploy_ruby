class PaymentPlansController < ApplicationController
  before_filter :authorize

	def index
    @shipping_instructions = ShippingInstruction.get_payments_plan(params)
    @report = PaymentPlanReport.new
    render "payments/index"
	end
  
	def report
		@report = PaymentPlanReport.new(report_params)
    generate_report(@report)
	end

	private
	def report_params
		params.require(:payment_plan_report).permit(:format, :monthly, :from, :to, row_ids: [], columns: [], row_ref_ids: [])
	end
end
