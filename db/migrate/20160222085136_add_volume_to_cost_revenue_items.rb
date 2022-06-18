class AddVolumeToCostRevenueItems < ActiveRecord::Migration
  def change
  	add_column :cost_revenue_items, :selling_volume, :decimal, :precision => 13, :scale => 2
  	add_column :cost_revenue_items, :buying_volume, :decimal, :precision => 13, :scale => 2
  end
end
