class AddIsDeletedToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :is_deleted, :boolean, default: false
    add_column :carrier_banks, :is_deleted, :boolean, default: false
    add_column :carriers, :is_deleted, :boolean, default: false
    add_column :consignees, :is_deleted, :boolean, default: false
    add_column :shippers, :is_deleted, :boolean, default: false
  end
end
