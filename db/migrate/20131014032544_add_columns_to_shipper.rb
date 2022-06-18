class AddColumnsToShipper < ActiveRecord::Migration
  def change
    add_column :shippers, :bl_address, :text, :null => false
  end
end
