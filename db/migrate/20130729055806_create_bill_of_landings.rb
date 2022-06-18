class CreateBillOfLandings < ActiveRecord::Migration
  def change
    create_table :bill_of_landings do |t|
      t.integer :shipping_instruction_id
      t.integer :shipper_id
      t.integer :consignee_id
      t.text :notify_party
      t.string :country_of_origin
      t.text :also_notify_party
      t.string :place_of_receipt
      t.string :port_of_loading
      t.string :port_of_discharge
      t.string :final_destination
      t.string :feeder_vessel
      t.string :connection_vessel
      t.text :marks_no
      t.text :description_packages
      t.string :gw
      t.string :measurement
      t.text :container_no
      t.string :freight
      t.text :freight_details
      t.string :no_of_obl
      t.date :date_of_issue
      t.text :shipped_on_board
      t.integer :create_by
      t.integer :update_by

      t.timestamps
    end
  end
end
