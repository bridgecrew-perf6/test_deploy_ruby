class ChangeStatusToIntShippingInstruction < ActiveRecord::Migration
  def change
  	change_column :bill_of_ladings, :status_tracking, :integer
  	change_column :debit_notes, :status, :integer
  	change_column :invoices, :status, :integer
  	change_column :shipping_instruction_histories, :status, :integer
  	change_column :shipping_instructions, :status, :integer
  end
end
