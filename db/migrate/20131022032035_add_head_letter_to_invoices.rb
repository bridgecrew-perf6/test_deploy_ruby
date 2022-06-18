class AddHeadLetterToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :head_letter, :string, :default => "INVOICE", :null => false
    add_column :debit_notes, :head_letter, :string, :default => "DEBIT NOTE", :null => false
  end
end
