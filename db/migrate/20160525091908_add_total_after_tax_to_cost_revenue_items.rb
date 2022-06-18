class AddTotalAfterTaxToCostRevenueItems < ActiveRecord::Migration
  def change
  	add_column :cost_revenue_items, :selling_total_after_tax, :decimal, :precision => 13, :scale => 2
  	add_column :cost_revenue_items, :buying_total_after_tax, :decimal, :precision => 13, :scale => 2
  end
end
