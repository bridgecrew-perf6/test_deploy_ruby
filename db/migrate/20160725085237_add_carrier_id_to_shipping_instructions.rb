class AddCarrierIdToShippingInstructions < ActiveRecord::Migration
  def change
  	add_column :shipping_instructions, :carrier_id, :integer
  end
end
