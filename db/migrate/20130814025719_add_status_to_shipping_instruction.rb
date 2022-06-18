class AddStatusToShippingInstruction < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :status, :boolean, :default => 0, :null => false
  end
end
