class AddVesselsAndSiContainersToShippingInstructionHistories < ActiveRecord::Migration
  def change
  	add_column :shipping_instruction_histories, :vessels, :text
  	add_column :shipping_instruction_histories, :si_containers, :text
  end
end
