class AddItemTypeToCostRevenueItems < ActiveRecord::Migration
  def change
  	add_column :cost_revenue_items, :item_type, :integer, :default => 1, :null => false
  end
end
