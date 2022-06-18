class CreateInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :invoice_details do |t|
      t.integer :invoice_id
      t.text :description
      t.decimal :amount, :precision => 13, :scale => 2
      t.integer :volume
    end
  end
end
