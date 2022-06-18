class AddCont2ToSi < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :container_no_2, :text
    add_column :shipping_instruction_histories, :container_no_2, :text
  end
end
