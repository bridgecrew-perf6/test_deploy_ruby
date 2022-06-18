class AddOwnerToCostRevenues < ActiveRecord::Migration
  def change
  	add_column :cost_revenues, :owner, :string
  end
end
