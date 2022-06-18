class ChangeVolumeDataTypeInShippingInstructions < ActiveRecord::Migration
  def change
  	change_column :shipping_instructions, :volume, :text
  	change_column :shipping_instruction_histories, :volume, :text
  end
end
