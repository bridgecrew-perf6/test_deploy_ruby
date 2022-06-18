class AddOwnerRefToCostRevenues < ActiveRecord::Migration
  def change
  	add_reference :cost_revenues, :owner, index: true
  end
end
