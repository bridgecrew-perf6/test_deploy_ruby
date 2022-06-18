class CreateConsignees < ActiveRecord::Migration
  def change
    create_table :consignees do |t|
      t.string :company_name
      t.text :address
      t.string :city
      t.string :zipcode
      t.string :country_id
      t.string :contact_name
      t.string :phone
      t.string :cellphone
      t.string :email_address
      t.text :custom_field1
      t.text :custom_field2
      t.text :custom_field3
    end
  end
end
