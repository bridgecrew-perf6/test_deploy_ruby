class AddShortpaidAndDepositColumnsToInvoicePayments < ActiveRecord::Migration
  def change
    add_column :invoice_payments, :short_paid_closing_date, :date
    add_column :invoice_payments, :short_paid_note, :text
    add_column :invoice_payments, :short_paid_status, :integer, default: 0, :null => false

    add_column :invoice_payments, :deposit_closing_date, :date
    add_column :invoice_payments, :deposit_note, :text
    add_column :invoice_payments, :deposit_status, :integer, default: 0, :null => false
  end
end
