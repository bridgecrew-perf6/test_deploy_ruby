class AddBlNoToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :bl_no, :string
    add_column :invoices, :ibl_no, :string
    add_column :debit_notes, :bl_no, :string
    add_column :debit_notes, :ibl_no, :string
    add_column :notes, :bl_no, :string
    add_column :notes, :ibl_no, :string

    # execute "UPDATE invoices SET bl_no = SUBTRING_INDEX(bl_ibl_no, '/', 1)"
    # execute "UPDATE invoices SET ibl_no = SUBTRING_INDEX(bl_ibl_no, '/', -1)"
    # execute "UPDATE debit_notes SET bl_no = SUBTRING_INDEX(bl_ibl_no, '/', 1)"
    # execute "UPDATE debit_notes SET ibl_no = SUBTRING_INDEX(bl_ibl_no, '/', -1)"
    # execute "UPDATE notes SET bl_no = SUBTRING_INDEX(bl_ibl_no, '/', 1)"
    # execute "UPDATE notes SET ibl_no = SUBTRING_INDEX(bl_ibl_no, '/', -1)"
  end
end
