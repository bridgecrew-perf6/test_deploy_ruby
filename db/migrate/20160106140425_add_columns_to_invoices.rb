class AddColumnsToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :tax_issued, :date
    add_column :invoices, :vat_10_no, :string
  	add_column :invoices, :vat_1_no, :string
  	add_column :invoices, :pph_23_no, :string
    add_column :invoices, :status_tax, :integer, default: 0, :null => false

    add_column :notes, :tax_issued, :date
    add_column :notes, :vat_10_no, :string
    add_column :notes, :vat_1_no, :string
  	add_column :notes, :pph_23_no, :string
    add_column :notes, :status_tax, :integer, default: 0, :null => false

    add_column :debit_notes, :tax_issued, :date
    add_column :debit_notes, :vat_10_no, :string
    add_column :debit_notes, :vat_1_no, :string
  	add_column :debit_notes, :pph_23_no, :string
    add_column :debit_notes, :status_tax, :integer, default: 0, :null => false
  end
end
