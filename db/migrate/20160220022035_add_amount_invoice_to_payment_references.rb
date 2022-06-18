class AddAmountInvoiceToPaymentReferences < ActiveRecord::Migration
  def change
  	add_column :payment_references, :amount_invoice, :decimal, :precision => 13, :scale => 2
  end
end
