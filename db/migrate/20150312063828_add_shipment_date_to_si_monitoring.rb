class AddShipmentDateToSiMonitoring < ActiveRecord::Migration
  def change
    add_column :si_monitorings, :shipment_date, :datetime
  end
end
