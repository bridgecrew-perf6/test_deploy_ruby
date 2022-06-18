class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :bill_of_landing_id
      t.string :no_invoice
      t.date :invoice_date
      t.date :due_date
      t.string :currency_code
      t.decimal :rate, :precision => 13, :scale => 2
      t.boolean :status

      t.timestamps
    end
  end
end
