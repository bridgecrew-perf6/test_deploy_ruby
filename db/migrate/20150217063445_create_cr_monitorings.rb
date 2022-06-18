class CreateCrMonitorings < ActiveRecord::Migration
  def change
    create_table :cr_monitorings do |t|
      t.belongs_to :cost_revenue, index: true
      t.string :hbl_no
      t.string :mbl_no
      t.boolean :hidden, default: false

      t.timestamps
    end
  end
end
