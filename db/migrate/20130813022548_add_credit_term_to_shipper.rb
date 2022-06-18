class AddCreditTermToShipper < ActiveRecord::Migration
  def change
    add_column :shippers, :credit_term, :integer, :default => 0, :null => false
  end
end
