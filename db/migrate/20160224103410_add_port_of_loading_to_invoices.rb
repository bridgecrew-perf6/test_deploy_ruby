class AddPortOfLoadingToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :port_of_loading, :string
    add_column :notes, :port_of_loading, :string
    add_column :debit_notes, :port_of_loading, :string
  end
end
