class CreateActualVessels < ActiveRecord::Migration
  def change
    create_table :actual_vessels do |t|
      t.belongs_to :shipment_tracking, index: true
      t.belongs_to :vessel, index: true
      t.date :actual_etd_date
      t.date :actual_eta_date
      t.integer :status_etd, default: 0
      t.integer :status_eta, default: 0
      t.text :reason_etd
      t.text :reason_eta

      t.timestamps
    end
  end
end
