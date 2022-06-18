class AddColumnsVatPphToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :add_vat_10, :boolean, :default => 0, :null => false
  	add_column :invoices, :add_vat_1, :boolean, :default => 0, :null => false
  	add_column :invoices, :add_total_include_vat, :boolean, :default => 0, :null => false
  	add_column :invoices, :add_pph_23, :boolean, :default => 0, :null => false
  	add_column :invoices, :add_total_after_pph_23, :boolean, :default => 0, :null => false
  	add_column :invoices, :add_rate, :boolean, :default => 0, :null => false

  	add_column :notes, :add_vat_10, :boolean, :default => 0, :null => false
  	add_column :notes, :add_vat_1, :boolean, :default => 0, :null => false
  	add_column :notes, :add_total_include_vat, :boolean, :default => 0, :null => false
  	add_column :notes, :add_pph_23, :boolean, :default => 0, :null => false
  	add_column :notes, :add_total_after_pph_23, :boolean, :default => 0, :null => false
  	add_column :notes, :add_rate, :boolean, :default => 0, :null => false

  	add_column :debit_notes, :add_vat_10, :boolean, :default => 0, :null => false
  	add_column :debit_notes, :add_vat_1, :boolean, :default => 0, :null => false
  	add_column :debit_notes, :add_total_include_vat, :boolean, :default => 0, :null => false
  	add_column :debit_notes, :add_pph_23, :boolean, :default => 0, :null => false
  	add_column :debit_notes, :add_total_after_pph_23, :boolean, :default => 0, :null => false
  	add_column :debit_notes, :add_rate, :boolean, :default => 0, :null => false
  end
end
