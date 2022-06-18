class AddShippingScheduleToShippingInstructions < ActiveRecord::Migration
  def change
  	add_column :shipping_instructions, :shipping_schedule, :text
  	add_column :shipping_instruction_histories, :shipping_schedule, :text
  end
end
