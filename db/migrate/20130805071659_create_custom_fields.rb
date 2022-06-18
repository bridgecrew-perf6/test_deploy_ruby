class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.string :field_key
      t.string :field_name
      t.text :field_value
      t.references :field, polymorphic: true
    end
  end
end
