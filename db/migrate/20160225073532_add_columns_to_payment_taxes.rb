class AddColumnsToPaymentTaxes < ActiveRecord::Migration
  def change
  	add_column :payment_taxes, :tax_no, :string
  	add_column :payment_taxes, :tax_issued, :date
  	add_column :payment_taxes, :is_paid, :boolean, default: false
  end
end
