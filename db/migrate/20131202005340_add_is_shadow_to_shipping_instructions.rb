class AddIsShadowToShippingInstructions < ActiveRecord::Migration
  def change
    add_column :shipping_instructions, :is_shadow, :boolean, default: false
  end
end
