class CreateBillOfLadingInvoices < ActiveRecord::Migration
  def change
    create_table :bill_of_lading_invoices do |t|
      t.references :bill_of_lading, index: true
      t.boolean :is_tick_all, default: false
      t.boolean :is_al, default: false
      t.boolean :is_gl, default: false

      t.timestamps
    end
  end
end
