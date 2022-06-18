class RenameBankToCarrierBankOnPayments < ActiveRecord::Migration
  def change
  	rename_column :payments, :bank_id, :carrier_bank_id
  	add_column :payments, :si_bl_no, :text
  	add_column :payments, :cash_carrier_name, :string
  end
end
