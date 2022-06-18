class AddItemTypeToInvoiceDetails < ActiveRecord::Migration
  def change
    add_column :invoice_details, :item_type, :integer, :default => 1, :null => false
    add_column :note_details, :item_type, :integer, :default => 1, :null => false
    add_column :debit_note_details, :item_type, :integer, :default => 1, :null => false
  end
end
