class AddColumnsToCostRevenues < ActiveRecord::Migration
  def change
    add_column :cost_revenues, :status, :integer, :default => 0, :null => false
    add_column :cost_revenues, :notes, :text
    execute "TRUNCATE cost_revenues"
    execute "TRUNCATE cost_revenue_items"
  end
end
