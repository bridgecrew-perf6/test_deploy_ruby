class RenameColumnDebitNote < ActiveRecord::Migration
  def change
  	rename_column :debit_notes, :currecy_code, :currency_code
  end
end
