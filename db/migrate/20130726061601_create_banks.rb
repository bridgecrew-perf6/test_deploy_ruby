class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :bank_name
      t.text :bank_address
      t.string :acc_name
      t.string :acc_no
      t.string :swift_code

      t.timestamps
    end
  end
end
