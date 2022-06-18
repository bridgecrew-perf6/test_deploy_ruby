class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :invoice_id
      t.integer :bank_id
      t.date :payment_date
      t.string :payment_no
      t.decimal :amount, :precision => 13, :scale => 2

      t.timestamps
    end
  end
end
