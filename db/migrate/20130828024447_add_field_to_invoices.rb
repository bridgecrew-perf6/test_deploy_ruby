class AddFieldToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :to_shipper, :text
    add_column :invoices, :vessel, :string
    add_column :invoices, :destination, :string
    add_column :invoices, :bl_ibl_no, :string
    add_column :invoices, :shipper_ref, :string
    add_column :invoices, :etd, :date
    add_column :invoices, :eta, :date
  end
end
