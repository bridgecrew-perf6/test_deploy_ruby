class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :unique => true
      t.string :email, :unique => true
      t.string :password_digest
      t.datetime :register_at
      t.datetime :login_at
      t.datetime :logout_at
      t.boolean :status, :default => 0
    end
  end
end
