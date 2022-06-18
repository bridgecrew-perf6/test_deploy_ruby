class AddShipperReferenceToShippingInstruction < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :shipper_reference, :string
  end
end
