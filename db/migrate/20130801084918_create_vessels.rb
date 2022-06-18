class CreateVessels < ActiveRecord::Migration
  def change
    create_table :vessels do |t|
      t.integer :shipping_instruction_id
      t.string :vessel_name
      t.integer :etd_no
      t.date :etd_date
      t.integer :eta_no
      t.date :eta_date
    end
  end
end
