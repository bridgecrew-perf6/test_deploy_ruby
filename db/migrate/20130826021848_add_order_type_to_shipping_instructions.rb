class AddOrderTypeToShippingInstructions < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :order_type, :string, :default => "", :null => false
  end
end
