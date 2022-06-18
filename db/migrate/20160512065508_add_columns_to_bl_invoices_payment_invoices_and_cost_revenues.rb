class AddColumnsToBlInvoicesPaymentInvoicesAndCostRevenues < ActiveRecord::Migration
  def change
  	add_column :bill_of_lading_invoices, :other, :decimal, :precision => 13, :scale => 2
  	add_column :bill_of_lading_invoices, :rate, :decimal, :precision => 13, :scale => 2
  	add_column :bill_of_lading_invoices, :vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :bill_of_lading_invoices, :vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :bill_of_lading_invoices, :pph_23, :decimal, :precision => 13, :scale => 2

  	add_column :payment_invoices, :other, :decimal, :precision => 13, :scale => 2
  	add_column :payment_invoices, :rate, :decimal, :precision => 13, :scale => 2
  	add_column :payment_invoices, :vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :payment_invoices, :vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :payment_invoices, :pph_23, :decimal, :precision => 13, :scale => 2

    add_column :cost_revenues, :selling_other, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :selling_rate, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :selling_vat_10, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :selling_vat_1, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :selling_pph_23, :decimal, :precision => 13, :scale => 2

    add_column :cost_revenues, :buying_other, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :buying_rate, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :buying_vat_10, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :buying_vat_1, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :buying_pph_23, :decimal, :precision => 13, :scale => 2
  end
end
