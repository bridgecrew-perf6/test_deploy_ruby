class AddNotesToShipper < ActiveRecord::Migration
  def change
    add_column :shippers, :notes, :text
  end
end
