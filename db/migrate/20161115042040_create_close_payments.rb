class CreateClosePayments < ActiveRecord::Migration
  def change
    create_table :close_payments do |t|
      t.references :invoice, index: true
    	t.string :ibl_ref
    	t.string :customer
      t.string :shipper
      t.string :invoice_no
      t.decimal :amount, precision: 13, scale: 2
      t.decimal :amount_paid, precision: 13, scale: 2
      t.decimal :rate, precision: 13, scale: 2
      t.date :payment_date
      t.integer :status, default: 0, :null => false
      t.string :currency
      t.integer :batch_id
      
      t.timestamps
    end
  end
end
