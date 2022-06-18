class AddDeliveryDocToBillOfLadings < ActiveRecord::Migration
  def change
    add_column :bill_of_ladings, :delivery_doc, :boolean, default: false
  end
end
