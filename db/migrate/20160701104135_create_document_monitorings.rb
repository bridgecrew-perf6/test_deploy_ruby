class CreateDocumentMonitorings < ActiveRecord::Migration
  def change
    create_table :document_monitorings do |t|
      t.belongs_to :shipping_instruction, index: true
      t.belongs_to :bill_of_lading, index: true
      t.string :ibl_ref
      t.string :shipper_company_name
      t.date :etd_date

      t.timestamps
    end
  end
end
