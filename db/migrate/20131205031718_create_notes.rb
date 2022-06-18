class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :bill_of_lading_id
      t.string :no_note
      t.date :note_date
      t.date :due_date
      t.string :currency_code
      t.decimal :rate, precision: 13, scale: 2
      t.integer :status, default: 0
      t.text :notes
      t.text :to_shipper
      t.string :vessel
      t.string :destination
      t.string :bl_ibl_no
      t.string :shipper_ref
      t.date :etd
      t.date :eta
      t.date :date_of_payment
      t.text :notes_payment
      t.integer :is_cancel, default: 0
      t.string :head_letter, default: "NOTE"

      t.timestamps
    end
    add_index :notes, :bill_of_lading_id
  end
end
