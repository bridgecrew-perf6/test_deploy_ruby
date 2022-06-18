class AddColumnsToShippingInstructions < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :booking_no, :string, :default => "", :null => false
    add_column :shipping_instruction_histories, :booking_no, :string, :default => "", :null => false
  end
end
