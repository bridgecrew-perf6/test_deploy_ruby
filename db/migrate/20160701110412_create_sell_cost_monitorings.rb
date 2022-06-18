class CreateSellCostMonitorings < ActiveRecord::Migration
  def change
    create_table :sell_cost_monitorings do |t|
      t.belongs_to :shipping_instruction, index: true
      t.belongs_to :cost_revenue, index: true
      t.string :ibl_ref
      t.string :shipper_company_name
      t.date :etd_date

      t.timestamps
    end
  end
end
