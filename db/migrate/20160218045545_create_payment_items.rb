class CreatePaymentItems < ActiveRecord::Migration
  def change
    create_table :payment_items do |t|
      t.references :payment_invoice, index: true
      t.string :description
      t.decimal :volume, :precision => 13, :scale => 2
      t.decimal :amount_usd, :precision => 13, :scale => 2
      t.decimal :amount_idr, :precision => 13, :scale => 2
      t.boolean :add_vat_10, default: false
      t.boolean :add_vat_1, default: false
      t.boolean :add_pph_23, default: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
