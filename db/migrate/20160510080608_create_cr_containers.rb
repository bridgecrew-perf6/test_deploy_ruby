class CreateCrContainers < ActiveRecord::Migration
  def change
    create_table :cr_containers do |t|
	  t.belongs_to :cost_revenue, index: true
      t.belongs_to :container, index: true
      t.string :volum
    end
  end
end
