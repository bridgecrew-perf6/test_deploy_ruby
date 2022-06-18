class AddOrderDetailsToShippingInstructions < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :order_details, :string, default: "", null: false
  end
end
