class ChangeConsigneeNameTypeInShippingInstructions < ActiveRecord::Migration
  def change
  	change_column :shipping_instructions, :consignee_name, :text, default: nil, null: true
	change_column :shipping_instruction_histories, :consignee_name, :text, default: nil, null: true

  	change_column :shipping_instructions, :shipper_name, :text, default: nil, null: true
	change_column :shipping_instruction_histories, :shipper_name, :text, default: nil, null: true

  	change_column :shipping_instructions, :freight, :text
	change_column :shipping_instruction_histories, :freight, :text

  	change_column :shipping_instructions, :dimension, :text
	change_column :shipping_instruction_histories, :dimension, :text

  	change_column :shipping_instructions, :hs_code, :text
	change_column :shipping_instruction_histories, :hs_code, :text
  end
end
