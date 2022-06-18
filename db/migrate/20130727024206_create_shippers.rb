class CreateShippers < ActiveRecord::Migration
  def change
    create_table :shippers do |t|
      t.string :company_name
      t.string :reference
      t.text :address
      t.string :city
      t.string :zipcode
      t.integer :country_id
      t.string :contact_name
      t.string :phone
      t.string :cellphone
      t.string :email_address
      t.string :custom_field1
      t.string :custom_field2
      t.string :custom_field3
    end
  end
end
