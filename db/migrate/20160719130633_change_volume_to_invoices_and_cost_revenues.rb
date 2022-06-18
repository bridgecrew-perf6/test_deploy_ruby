class ChangeVolumeToInvoicesAndCostRevenues < ActiveRecord::Migration
  def change
    change_column :cost_revenue_items, :selling_volume, :decimal, precision: 13, scale: 5, default: 1
    change_column :cost_revenue_items, :buying_volume, :decimal, precision: 13, scale: 5, default: 1

    change_column :payment_items, :volume, :decimal, precision: 13, scale: 5, default: 1
    change_column :bill_of_lading_items, :volume, :decimal, precision: 13, scale: 5, default: 1
  end
end
