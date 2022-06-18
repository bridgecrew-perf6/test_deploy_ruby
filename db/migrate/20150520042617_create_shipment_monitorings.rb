class CreateShipmentMonitorings < ActiveRecord::Migration
  def change
    create_table :shipment_monitorings do |t|
      t.integer :shipping_instruction_id
      t.integer :shipment_tracking_id
      t.string :hbl_no
      t.string :mbl_no
      t.date :shipment_date

      t.timestamps
    end
  end
end
