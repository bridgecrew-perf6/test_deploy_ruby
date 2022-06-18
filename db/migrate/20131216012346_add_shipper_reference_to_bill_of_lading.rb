class AddShipperReferenceToBillOfLading < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :shipper_reference, :string
  end
end
