class AddColumnsToSibl < ActiveRecord::Migration
  def change
	add_column :shipping_instructions, :shipper_name, :string, :default => "", :null => false
	add_column :shipping_instructions, :consignee_name, :string, :default => "", :null => false
	add_column :shipping_instruction_histories, :shipper_name, :string, :default => "", :null => false
	add_column :shipping_instruction_histories, :consignee_name, :string, :default => "", :null => false
	add_column :bill_of_ladings, :shipper_name, :string, :default => "", :null => false
	add_column :bill_of_ladings, :consignee_name, :string, :default => "", :null => false
	add_column :bill_of_lading_histories, :shipper_name, :string, :default => "", :null => false
	add_column :bill_of_lading_histories, :consignee_name, :string, :default => "", :null => false
  end
end
