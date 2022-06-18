class AddColumnsToBillOfLadings < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :status_tracking, :boolean, :default => false, :null => false
  end
end
