class AddShippingInstructionIdToCrMonitorings < ActiveRecord::Migration
  def change
    add_column :cr_monitorings, :shipping_instruction_id, :integer
    add_index :cr_monitorings, :shipping_instruction_id
  end
end
