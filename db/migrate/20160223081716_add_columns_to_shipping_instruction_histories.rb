class AddColumnsToShippingInstructionHistories < ActiveRecord::Migration
  def change
  	add_column :shipping_instruction_histories, :is_cancel, :integer, :default => 0, :null => false
  	add_column :shipping_instruction_histories, :order_details, :string, default: "", null: false
	add_column :shipping_instruction_histories, :is_shadow, :boolean, default: false
  end
end
