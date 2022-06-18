class AddOtherVatPphToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :other, :decimal, :precision => 13, :scale => 2
  	# add_column :invoices, :rate, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :pph_23, :decimal, :precision => 13, :scale => 2

  	add_column :debit_notes, :other, :decimal, :precision => 13, :scale => 2
  	# add_column :debit_notes, :rate, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :pph_23, :decimal, :precision => 13, :scale => 2

  	add_column :notes, :other, :decimal, :precision => 13, :scale => 2
  	# add_column :notes, :rate, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :vat_10, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :vat_1, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :pph_23, :decimal, :precision => 13, :scale => 2
  end
end
