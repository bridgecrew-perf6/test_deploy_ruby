class CreateBlMonitorings < ActiveRecord::Migration
  def change
    create_table :bl_monitorings do |t|
      t.belongs_to :bill_of_lading, index: true
      t.string :hbl_no
      t.string :mbl_no
      t.boolean :invoiced, default: false
      t.boolean :closed, default: false
      t.boolean :hidden, default: false
      t.datetime :shipment_date

      t.timestamps
    end
  end
end
