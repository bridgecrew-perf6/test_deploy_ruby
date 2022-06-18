class RenameInvoicesColumn < ActiveRecord::Migration
  def change
  	rename_column :invoices, :bill_of_landing_id, :bill_of_lading_id
  end
end
