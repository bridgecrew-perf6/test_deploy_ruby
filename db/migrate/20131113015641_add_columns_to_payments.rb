class AddColumnsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_type, :string, default: "", null: false
    add_column :payments, :notes, :text
    add_column :payments, :status, :integer, default: 0, null: false
    add_column :payments, :is_cancel, :integer, default: 0, null: false

  	execute "UPDATE payments SET payment_type = 'USD' WHERE payment_no LIKE '%USD%'"
  	execute "UPDATE payments SET payment_type = 'IDR' WHERE payment_no LIKE '%IDR%'"
  	execute "TRUNCATE payments"
  end
end
