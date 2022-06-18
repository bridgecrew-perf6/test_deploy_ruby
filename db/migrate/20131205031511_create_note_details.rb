class CreateNoteDetails < ActiveRecord::Migration
  def change
    create_table :note_details do |t|
      t.integer :note_id
      t.text :description
      t.decimal :amount, precision: 13, scale: 2
      t.integer :volume
    end
    add_index :note_details, :note_id
  end
end
