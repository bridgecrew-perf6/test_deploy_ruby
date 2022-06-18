class AddColumns2ToShippingInstructions < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :trade, :string
    add_column :shipping_instructions, :handle_by, :integer

    add_column :shipping_instruction_histories, :trade, :string
    add_column :shipping_instruction_histories, :handle_by, :integer
  end
end
