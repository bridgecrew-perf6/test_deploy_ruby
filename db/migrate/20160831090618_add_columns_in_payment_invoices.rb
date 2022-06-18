class AddColumnsInPaymentInvoices < ActiveRecord::Migration
  def change
    add_column :payment_invoices, :vat_10_tax_no, :string
    add_column :payment_invoices, :vat_1_tax_no, :string
  	add_column :payment_invoices, :pph_23_tax_no, :string

    add_column :payment_invoices, :vat_10_tax_issued, :date
    add_column :payment_invoices, :vat_1_tax_issued, :date
    add_column :payment_invoices, :pph_23_tax_issued, :date

    add_column :payment_invoices, :vat_10_invoice_no, :string
    add_column :payment_invoices, :vat_1_invoice_no, :string
  	add_column :payment_invoices, :pph_23_invoice_no, :string

    add_column :payment_invoices, :vat_10_status, :integer, default: 0, :null => false
    add_column :payment_invoices, :vat_1_status, :integer, default: 0, :null => false
    add_column :payment_invoices, :pph_23_status, :integer, default: 0, :null => false
  end
end
