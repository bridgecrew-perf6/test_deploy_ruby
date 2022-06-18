class AddAddaAddbAddcToCostRevenues < ActiveRecord::Migration
  def change
  	add_column :cost_revenues, :adda, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :addb, :decimal, :precision => 13, :scale => 2
    add_column :cost_revenues, :addc, :decimal, :precision => 13, :scale => 2
  end
end
