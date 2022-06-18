class AddColumnsToTable < ActiveRecord::Migration
  def change
  	add_column :shipping_instructions, :is_cancel, :integer, :default => 0, :null => false
  	add_column :bill_of_ladings, :is_cancel, :integer, :default => 0, :null => false
  	add_column :invoices, :is_cancel, :integer, :default => 0, :null => false
  	add_column :debit_notes, :is_cancel, :integer, :default => 0, :null => false
  end
end
