class AddBlNumberToBillOfLanding < ActiveRecord::Migration
  def change
  	add_column :bill_of_landings, :bl_number, :string
  end
end
