class AddColumnsToConsignee < ActiveRecord::Migration
  def change
  	add_column :carriers, :address, :text
  	add_column :carriers, :reference, :string, :default => ""
  	add_column :carriers, :credit_term, :integer, :default => 0
  	add_column :consignees, :reference, :string, :default => ""
  	add_column :consignees, :credit_term, :integer, :default => 0
  end
end
