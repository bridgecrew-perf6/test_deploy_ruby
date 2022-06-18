class CreateInvoiceCloseDeposits < ActiveRecord::Migration
  def change
    create_table :invoice_close_deposits do |t|
      t.string :invoice_no
      t.date :payment_date
      t.decimal :amount, precision: 13, scale: 2
      t.text :note

      t.timestamps
    end
  end
end
