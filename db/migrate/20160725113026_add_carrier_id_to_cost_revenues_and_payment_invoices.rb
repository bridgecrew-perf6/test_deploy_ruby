class AddCarrierIdToCostRevenuesAndPaymentInvoices < ActiveRecord::Migration
  def change
  	add_column :cost_revenues, :carrier_id, :integer
  	add_column :payment_invoices, :carrier_id, :integer
  end
end
