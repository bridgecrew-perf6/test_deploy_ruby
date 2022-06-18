class AddMasterBlNoToBillOfLadings < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :master_bl_no, :string, :default => "", :null => false
  end
end
