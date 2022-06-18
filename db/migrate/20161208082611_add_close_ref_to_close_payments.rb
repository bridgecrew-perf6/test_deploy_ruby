class AddCloseRefToClosePayments < ActiveRecord::Migration
  def change
    add_column :close_payments, :close_ref, :string
    add_column :close_payments, :is_shadow, :boolean, default: false
  end
end
