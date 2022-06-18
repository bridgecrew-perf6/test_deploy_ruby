class CreateCarrierItems < ActiveRecord::Migration
  def change
    create_table :carrier_items do |t|
      t.references :carrier, index: true
      t.string :description
      t.decimal :amount_usd, :precision => 13, :scale => 2
      t.decimal :amount_idr, :precision => 13, :scale => 2
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
