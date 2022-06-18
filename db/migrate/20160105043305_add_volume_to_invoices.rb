class AddVolumeToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :volume, :string
    add_column :notes, :volume, :string
    add_column :debit_notes, :volume, :string
  end
end
