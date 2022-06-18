class CreateInvoiceMonitorings < ActiveRecord::Migration
  def change
    create_table :invoice_monitorings do |t|
      t.belongs_to :shipping_instruction, index: true
      t.belongs_to :invoice, index: true
      t.belongs_to :debit_note, index: true
      t.belongs_to :note, index: true
      t.string :ibl_ref
      t.string :invoice_no
      t.string :shipper_company_name
      t.date :etd_date

      t.timestamps
    end
  end
end
