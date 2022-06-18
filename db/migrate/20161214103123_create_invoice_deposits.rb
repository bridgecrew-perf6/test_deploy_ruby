class CreateInvoiceDeposits < ActiveRecord::Migration
  def change
    create_table :invoice_deposits do |t|
      t.references :invoice, index: true
      t.references :close_payment, index: true
      t.string :ibl_deposit
      t.string :invoice_deposit
      t.decimal :amount, precision: 13, scale: 2
      t.string :invoice_no

      t.timestamps
    end
  end
end
