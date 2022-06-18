class CreateCommisionMonitorings < ActiveRecord::Migration
  def change
    create_table :commision_monitorings do |t|
      t.belongs_to :shipping_instruction, index: true
      t.belongs_to :cost_revenue, index: true
      t.string :hbl_no
      t.string :mbl_no
      t.boolean :exported, default: false
      t.datetime :exported_at
      t.boolean :hidden, default: false

      t.timestamps
    end
  end
end
