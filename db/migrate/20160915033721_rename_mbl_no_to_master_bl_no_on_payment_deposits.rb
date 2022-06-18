class RenameMblNoToMasterBlNoOnPaymentDeposits < ActiveRecord::Migration
  def change
  	rename_column :payment_deposits, :mbl_no, :master_bl_no
  end
end
