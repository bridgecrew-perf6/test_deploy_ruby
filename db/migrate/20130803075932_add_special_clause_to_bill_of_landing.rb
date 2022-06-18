class AddSpecialClauseToBillOfLanding < ActiveRecord::Migration
  def change
  	add_column :bill_of_landings, :special_clause, :text
  end
end