class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :name
      t.text :address
      t.string :reference
      t.integer :credit_term
      t.text :notes

      t.timestamps
    end
  end
end
