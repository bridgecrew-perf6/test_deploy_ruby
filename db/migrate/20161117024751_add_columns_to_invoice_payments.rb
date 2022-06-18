class AddColumnsToInvoicePayments < ActiveRecord::Migration
  def change
    add_column :invoice_payments, :ibl_ref, :string
    add_column :invoice_payments, :invoice_no, :string
    add_column :invoice_payments, :pph_23, :decimal, :precision => 13, :scale => 2
    add_column :invoice_payments, :other, :decimal, :precision => 13, :scale => 2
  	add_reference :invoice_payments, :close_payment, index: true
  end
end
