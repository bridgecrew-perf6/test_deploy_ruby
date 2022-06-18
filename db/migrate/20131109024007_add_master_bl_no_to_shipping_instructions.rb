class AddMasterBlNoToShippingInstructions < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :master_bl_no, :string, default: ""
    add_column :shipping_instruction_histories, :master_bl_no, :string, default: ""
  end
end
