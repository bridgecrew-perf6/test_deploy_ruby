class ChangeVolumeDefaultInCostRevenueItems < ActiveRecord::Migration
  def change
    remove_column :cost_revenue_items, :selling_volume, :decimal, :precision => 13, :scale => 2
    remove_column :cost_revenue_items, :buying_volume, :decimal, :precision => 13, :scale => 2

    add_column :cost_revenue_items, :selling_volume, :decimal, :precision => 13, :scale => 2, default: 1
    add_column :cost_revenue_items, :buying_volume, :decimal, :precision => 13, :scale => 2, default: 1
  end
end
