class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :container_type
      t.string :length
      t.string :width
      t.string :height
      t.string :capacity
      t.string :load
      t.string :container_weight
      t.string :max_gross_weight
    end
  end
end
