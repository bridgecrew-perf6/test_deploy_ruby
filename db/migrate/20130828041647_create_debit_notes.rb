class CreateDebitNotes < ActiveRecord::Migration
  def change
    create_table :debit_notes do |t|
      t.integer :bill_of_lading_id
      t.string :no_dbn
      t.date :dbn_date
      t.date :due_date
      t.string :currecy_code
      t.decimal :rate, precision: 13, scale: 2
      t.boolean :status
      t.text :notes
      t.text :to_shipper
      t.string :vessel
      t.string :destination
      t.string :bl_ibl_no
      t.string :shipper_ref
      t.date :etd
      t.date :eta

      t.timestamps
    end
  end
end
