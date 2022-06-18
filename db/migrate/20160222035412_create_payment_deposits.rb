class CreatePaymentDeposits < ActiveRecord::Migration
  def change
    create_table :payment_deposits do |t|
      t.belongs_to :payment, index: true
      t.string :ibl_deposit
      t.string :mbl_no
      t.decimal :amount, precision: 13, scale: 2
      t.string :ibl_ref

      t.timestamps
    end
  end
end
