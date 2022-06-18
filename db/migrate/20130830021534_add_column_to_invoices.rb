class AddColumnToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :date_of_payment, :date
    add_column :invoices, :notes_payment, :text
    add_column :debit_notes, :date_of_payment, :date
    add_column :debit_notes, :notes_payment, :text
  end
end
