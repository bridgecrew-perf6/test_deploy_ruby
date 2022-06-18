class CreateCostRevenues < ActiveRecord::Migration
  def change
    create_table :cost_revenues do |t|
      t.belongs_to :shipping_instruction, index: true
      t.text :payment_no

      t.timestamps
    end
  end
end