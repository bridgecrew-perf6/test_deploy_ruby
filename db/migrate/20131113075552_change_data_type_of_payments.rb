class ChangeDataTypeOfPayments < ActiveRecord::Migration
  def change
  	change_column :payments, :amount, :string, :default => "0", :null => false
  	change_column :payment_references, :amount, :string, :default => "0", :null => false
  end
end
