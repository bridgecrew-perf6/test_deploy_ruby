class AddItemTypeToBlAndPaymentItems < ActiveRecord::Migration
  def change
    add_column :bill_of_lading_items, :item_type, :integer, :default => 1, :null => false
    add_column :payment_items, :item_type, :integer, :default => 1, :null => false
  end
end
