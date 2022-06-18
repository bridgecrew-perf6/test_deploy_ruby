class ChangeStatusToInvoices < ActiveRecord::Migration
  def change
  	change_column :invoices, :status, :integer, default: 0
  	change_column :debit_notes, :status, :integer, default: 0
  	
  	execute "UPDATE invoices SET status = 0 WHERE status IS NULL"
  	execute "UPDATE debit_notes SET status = 0 WHERE status IS NULL"
  end
end
