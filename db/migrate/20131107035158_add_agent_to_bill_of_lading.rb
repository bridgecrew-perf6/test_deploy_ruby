class AddAgentToBillOfLading < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :agent_id, :integer
    add_column :bill_of_ladings, :agent_name, :text
    add_index :bill_of_ladings, :agent_id
    add_column :bill_of_lading_histories, :agent_id, :integer
    add_column :bill_of_lading_histories, :agent_name, :text
    add_index :bill_of_lading_histories, :agent_id
  end
end
