class AddStatusPaymentToInvoices < ActiveRecord::Migration
  def up
    add_column :invoices, :status_payment, :integer, default: 0
    add_column :notes, :status_payment, :integer, default: 0
    add_column :debit_notes, :status_payment, :integer, default: 0

    execute "UPDATE invoices SET status_payment = status"
    execute "UPDATE notes SET status_payment = status"
    execute "UPDATE debit_notes SET status_payment = status"
  end

  def down
    remove_column :invoices, :status_payment
    remove_column :notes, :status_payment
    remove_column :debit_notes, :status_payment
  end
end
