class AddHideAgentToBillOfLading < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :hide_agent, :boolean, default: false
  end
end
