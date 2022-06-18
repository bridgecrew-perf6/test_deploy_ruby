class ChangeShipperNameLimitToShippingInstruction < ActiveRecord::Migration
  def change
  	change_column :shipping_instructions, :shipper_name, :text, :limit => 4294967295
  end
end
