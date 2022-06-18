class AddDefaultFieldsToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :default_total_amount, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :default_vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :default_vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :default_total_include_vat, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :default_pph_23, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :default_total_after_pph_23, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :default_rate, :decimal, :precision => 13, :scale => 2
  	
  	add_column :notes, :default_total_amount, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :default_vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :default_vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :default_total_include_vat, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :default_pph_23, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :default_total_after_pph_23, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :default_rate, :decimal, :precision => 13, :scale => 2
  	
  	add_column :debit_notes, :default_total_amount, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :default_vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :default_vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :default_total_include_vat, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :default_pph_23, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :default_total_after_pph_23, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :default_rate, :decimal, :precision => 13, :scale => 2
  	
  	add_column :invoice_details, :default_amount, :decimal, :precision => 13, :scale => 2
  	add_column :note_details, :default_amount, :decimal, :precision => 13, :scale => 2
  	add_column :debit_note_details, :default_amount, :decimal, :precision => 13, :scale => 2
  end
end
