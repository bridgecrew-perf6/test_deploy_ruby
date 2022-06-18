class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :code
      t.string :name
      t.integer :region_id
      t.string :currency_code
      t.string :currency_name
    end
  end
end
