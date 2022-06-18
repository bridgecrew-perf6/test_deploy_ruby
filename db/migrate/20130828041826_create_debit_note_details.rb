class CreateDebitNoteDetails < ActiveRecord::Migration
  def change
    create_table :debit_note_details do |t|
      t.integer :debit_note_id
      t.text :description
      t.decimal :amount, precision: 13, scale: 2
      t.integer :volume

      t.timestamps
    end
  end
end
