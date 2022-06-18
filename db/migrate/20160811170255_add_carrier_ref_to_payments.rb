class AddCarrierRefToPayments < ActiveRecord::Migration
  def change
    add_reference :payments, :carrier, index: true
  end
end
