class CreateShipmentTrackings < ActiveRecord::Migration
  def change
    create_table :shipment_trackings do |t|
      t.belongs_to :shipping_instruction, index: true
      t.text :notes
      t.string :free_request
      t.string :free_approval
      t.integer :free_status, default: 0

      t.timestamps
    end
  end
end
