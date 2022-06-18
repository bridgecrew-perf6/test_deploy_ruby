class AddFuDateToShipmentTrackings < ActiveRecord::Migration
  def change
    add_column :shipment_trackings, :fu_date, :date
  end
end
