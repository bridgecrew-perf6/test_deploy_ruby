class AddTotalAfterTaxToCostRevenues < ActiveRecord::Migration
  def change
  	add_column :cost_revenues, :selling_total_after_tax, :decimal, :precision => 13, :scale => 2
  	add_column :cost_revenues, :buying_total_after_tax, :decimal, :precision => 13, :scale => 2
  end
end
