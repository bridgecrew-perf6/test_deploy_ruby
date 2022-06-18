class AddAmountPaymentToPaymentReferences < ActiveRecord::Migration
  def change
  	add_column :payment_references, :amount_payment, :decimal, :precision => 13, :scale => 2
  end
end
