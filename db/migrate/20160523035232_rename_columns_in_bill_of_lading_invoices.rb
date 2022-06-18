class RenameColumnsInBillOfLadingInvoices < ActiveRecord::Migration
  def change
  	rename_column :bill_of_lading_invoices, :is_al, :is_ai
  	rename_column :bill_of_lading_invoices, :is_gl, :is_gi
  end
end
