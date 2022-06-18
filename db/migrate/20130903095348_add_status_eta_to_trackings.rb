class AddStatusEtaToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :status_eta, :integer, :default => 0, :null => false
  end
end
