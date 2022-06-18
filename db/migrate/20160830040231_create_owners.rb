class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :name
      t.string :reference
      t.text :notes
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
