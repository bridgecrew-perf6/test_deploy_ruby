class CreatePaymentInvoices < ActiveRecord::Migration
  def change
    create_table :payment_invoices do |t|
      t.references :payment, index: true
      t.date :payment_date
      t.string :carrier
      t.boolean :is_paid, default: false

      t.timestamps
    end
  end
end
