class CreatePaymentReferences < ActiveRecord::Migration
  def change
    create_table :payment_references do |t|
      t.belongs_to :payment, index: true
      t.string :ibl_ref
      t.string :booking_no
      t.decimal :amount, precision: 13, scale: 2

      t.timestamps
    end
  end
end
