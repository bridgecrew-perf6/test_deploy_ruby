class AddShipmentDateToCrMonitoring < ActiveRecord::Migration
  def change
    add_column :cr_monitorings, :shipment_date, :datetime
  end
end
