class CreateCarrierBanks < ActiveRecord::Migration
  def change
    create_table :carrier_banks do |t|
      t.integer :carrier_id
      t.string :bank_name
      t.string :bank_address
      t.string :acc_name
      t.string :acc_no
      t.string :swift_code
      t.string :currency
      t.string :branch

      t.timestamps
    end
  end
end
