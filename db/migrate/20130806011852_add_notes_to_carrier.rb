class AddNotesToCarrier < ActiveRecord::Migration
  def change
    add_column :carriers, :notes, :text
  end
end
