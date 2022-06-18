class ChangeEtdDataTypeInVessel < ActiveRecord::Migration
  def change
  	change_column :vessels, :etd_no, :string
  	change_column :vessels, :eta_no, :string
  end
end
