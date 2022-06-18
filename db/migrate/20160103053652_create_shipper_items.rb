class CreateShipperItems < ActiveRecord::Migration
  def change
    create_table :shipper_items do |t|
      t.references :shipper, index: true
      t.string :description
      t.decimal :amount_usd, :precision => 13, :scale => 2
      t.decimal :amount_idr, :precision => 13, :scale => 2
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
