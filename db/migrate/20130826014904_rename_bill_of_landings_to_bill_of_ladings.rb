class RenameBillOfLandingsToBillOfLadings < ActiveRecord::Migration
  def change
  	rename_table :bill_of_landings, :bill_of_ladings
  end
end
