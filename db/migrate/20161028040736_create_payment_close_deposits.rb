class CreatePaymentCloseDeposits < ActiveRecord::Migration
  def change
    create_table :payment_close_deposits do |t|
      t.belongs_to :carrier, index: true
      # t.belongs_to :shipping_instruction, index: true
      t.string :ibl_ref
      t.string :payment_type, default: "", null: false
      t.date :payment_date
      t.decimal :amount, precision: 13, scale: 2
      t.text :note

      # t.date :payment_date_2
      # t.decimal :amount_2, precision: 13, scale: 2
      # t.text :note_2
      
      t.timestamps
    end
  end
end
