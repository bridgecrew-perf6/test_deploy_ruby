class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.integer :assetable_id
      t.string :assetable_type
      t.attachment :asset

      t.timestamps
    end
  end
end
