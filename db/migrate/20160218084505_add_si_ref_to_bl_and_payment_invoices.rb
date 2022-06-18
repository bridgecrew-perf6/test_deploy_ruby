class AddSiRefToBlAndPaymentInvoices < ActiveRecord::Migration
  def change
  	add_reference :bill_of_lading_invoices, :shipping_instruction, index: true
  	add_reference :payment_invoices, :shipping_instruction, index: true
  end
end
