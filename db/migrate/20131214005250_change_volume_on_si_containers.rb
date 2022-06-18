class ChangeVolumeOnSiContainers < ActiveRecord::Migration
  def change
  	change_column :si_containers, :volum, :string
  end
end
