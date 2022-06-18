class AddCustomerToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :customer, :string
    add_column :debit_notes, :customer, :string
    add_column :notes, :customer, :string
  end
end
