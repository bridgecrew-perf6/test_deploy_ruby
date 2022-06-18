class AddColumnsToPaymentReferences < ActiveRecord::Migration
  def change
  	add_column :payment_references, :master_bl_no, :string
    add_column :payment_references, :amount_misc, :decimal, :precision => 13, :scale => 2
  	add_column :payment_references, :amount_overpaid, :decimal, :precision => 13, :scale => 2
  end
end
