class CreateShippingInstructions < ActiveRecord::Migration
  def change
    create_table :shipping_instructions do |t|
      t.string :si_no
      t.integer :shipper_id
      t.integer :consignee_id
      t.text :notify_party
      t.string :country_of_origin
      t.string :carrier
      t.string :pic
      t.string :feeder_vessel
      t.string :connection_vessel
      t.date :etd_jkt
      t.date :etd_sin
      t.date :eta
      t.integer :volume
      t.integer :container_id
      t.string :place_of_receipt
      t.string :port_of_loading
      t.string :port_of_transhipment
      t.string :port_of_discharge
      t.string :final_destination
      t.string :no_of_obl
      t.date :si_date
      t.text :marks_no
      t.text :description_packages
      t.string :gw
      t.string :nw
      t.string :measurement
      t.string :dimension
      t.string :freight
      t.text :freight_details
      t.text :special_instructions
      t.text :container_no
      t.string :peb_no
      t.date :inst_date
      t.string :kpbc
      t.string :hs_code
      t.integer :create_by
      t.integer :update_by

      t.timestamps
    end
  end
end
