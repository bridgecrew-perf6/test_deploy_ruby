class CreateBillOfLadingHistories < ActiveRecord::Migration
  def change
    create_table :bill_of_lading_histories do |t|
      t.integer :bill_of_lading_id
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
      t.string :bl_number
      t.string :place_of_issue
      t.text :special_clause
      t.string :master_bl_no

      t.timestamps
    end
  end
end
