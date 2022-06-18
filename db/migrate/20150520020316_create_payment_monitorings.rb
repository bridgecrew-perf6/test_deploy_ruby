class CreatePaymentMonitorings < ActiveRecord::Migration
  def change
    create_table :payment_monitorings do |t|
      t.integer :shipping_instruction_id
      t.string :hbl_no
      t.string :carrier
      t.date :shipment_date

      t.timestamps
    end
    add_index :payment_monitorings, :shipping_instruction_id
  end
end
