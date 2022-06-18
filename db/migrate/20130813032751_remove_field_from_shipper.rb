class RemoveFieldFromShipper < ActiveRecord::Migration
  def change
    remove_column :shippers, :address, :text
    remove_column :shippers, :city, :string
    remove_column :shippers, :zipcode, :string
    remove_column :shippers, :country_id, :integer
    remove_column :shippers, :contact_name, :string
    remove_column :shippers, :phone, :string
    remove_column :shippers, :cellphone, :string
    remove_column :shippers, :email_address, :string
    remove_column :shippers, :custom_field1, :string
    remove_column :shippers, :custom_field2, :string
    remove_column :shippers, :custom_field3, :string
  end
end
