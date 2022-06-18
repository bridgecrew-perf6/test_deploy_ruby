class AddColumnsToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :etd_actual_date, :date
    add_column :trackings, :etd_desc, :text
    add_column :trackings, :eta_actual_date, :date
    add_column :trackings, :eta_desc, :text
  end
end
