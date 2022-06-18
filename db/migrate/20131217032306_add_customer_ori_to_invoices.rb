class AddCustomerOriToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :customer_ori, :string
    add_column :debit_notes, :customer_ori, :string
    add_column :notes, :customer_ori, :string
  end
end
