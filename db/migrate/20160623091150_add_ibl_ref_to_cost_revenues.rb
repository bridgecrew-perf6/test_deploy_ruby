class AddIblRefToCostRevenues < ActiveRecord::Migration
  def change
  	add_column :cost_revenues, :ibl_ref, :string
  end
end
