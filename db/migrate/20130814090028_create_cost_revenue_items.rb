class CreateCostRevenueItems < ActiveRecord::Migration
  def change
    create_table :cost_revenue_items do |t|
      t.belongs_to :cost_revenue, index: true
      t.string :description
      t.decimal :selling_usd, precision: 13, scale: 2
      t.decimal :selling_idr, precision: 13, scale: 2
      t.decimal :buying_usd, precision: 13, scale: 2
      t.decimal :buying_idr, precision: 13, scale: 2

      t.timestamps
    end
  end
end
