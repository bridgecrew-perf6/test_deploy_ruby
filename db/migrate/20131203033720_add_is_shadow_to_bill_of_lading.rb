class AddIsShadowToBillOfLading < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :is_shadow, :boolean, default: false
  end
end
