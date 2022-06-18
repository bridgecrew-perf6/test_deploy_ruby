class RenameColumnsInCostRevenues < ActiveRecord::Migration
  def change
  	rename_column :cost_revenues, :first_etd_date, :etd_date
  	rename_column :cost_revenues, :first_vessel_name, :vessel_name
  end
end
