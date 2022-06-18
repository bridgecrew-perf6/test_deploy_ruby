class AddInvoiceReferenceToBillOfLadingItems < ActiveRecord::Migration
  def change
  	add_reference :bill_of_lading_items, :bill_of_lading_invoice, index: true
  end
end
