class ChangeVatStatusToPaymentInvoices < ActiveRecord::Migration
  def change
    change_column :payment_invoices, :vat_10_status, :boolean, default: false
    change_column :payment_invoices, :vat_1_status, :boolean, default: false
    change_column :payment_invoices, :pph_23_status, :boolean, default: false
  end
end
