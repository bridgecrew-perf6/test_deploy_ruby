class AddVat2ToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :vat_10_2, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :vat_1_2, :decimal, :precision => 13, :scale => 2
  	add_column :invoices, :pph_23_2, :decimal, :precision => 13, :scale => 2


  	add_column :debit_notes, :vat_10_2, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :vat_1_2, :decimal, :precision => 13, :scale => 2
  	add_column :debit_notes, :pph_23_2, :decimal, :precision => 13, :scale => 2

  	add_column :notes, :vat_10_2, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :vat_1_2, :decimal, :precision => 13, :scale => 2
  	add_column :notes, :pph_23_2, :decimal, :precision => 13, :scale => 2
  end
end
