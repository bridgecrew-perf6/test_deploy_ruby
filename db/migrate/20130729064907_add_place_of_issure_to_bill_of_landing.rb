class AddPlaceOfIssureToBillOfLanding < ActiveRecord::Migration
  def change
  	add_column :bill_of_landings, :place_of_issue, :string
  end
end
