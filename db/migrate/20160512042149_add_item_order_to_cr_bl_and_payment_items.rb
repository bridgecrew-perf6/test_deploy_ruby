class AddItemOrderToCrBlAndPaymentItems < ActiveRecord::Migration
  def change
  	add_column :cost_revenue_items, :item_order, :integer, :default => 0, :null => false
    add_column :bill_of_lading_items, :item_order, :integer, :default => 0, :null => false
    add_column :payment_items, :item_order, :integer, :default => 0, :null => false
  end
end
