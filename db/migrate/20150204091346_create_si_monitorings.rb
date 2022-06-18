class CreateSiMonitorings < ActiveRecord::Migration
  def change
    create_table :si_monitorings do |t|
      t.belongs_to :shipping_instruction, index: true
      t.string :si_no
      t.boolean :hidden, default: false

      t.timestamps
    end
  end
end
