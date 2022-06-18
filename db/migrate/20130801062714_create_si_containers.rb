class CreateSiContainers < ActiveRecord::Migration
  def change
    create_table :si_containers do |t|
      t.integer :shipping_instruction_id
      t.integer :container_id
      t.integer :volum
    end
  end
end
