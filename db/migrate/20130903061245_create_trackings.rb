class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.belongs_to :bill_of_lading, index: true
      t.string :vessel
      t.string :etd_no
      t.date :etd_date
      t.string :eta_no
      t.date :eta_date
      t.integer :status

      t.timestamps
    end
  end
end
