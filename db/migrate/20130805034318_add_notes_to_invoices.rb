class AddNotesToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :notes, :text
  end
end
