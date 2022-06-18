class ChangeColumnsDetailsToInvoice < ActiveRecord::Migration
  def up
  	change_column :debit_note_details, :volume, :decimal, precision: 13, scale: 5
  	change_column :invoice_details, :volume, :decimal, precision: 13, scale: 5
  	change_column :note_details, :volume, :decimal, precision: 13, scale: 5
  end

  def down
  	change_column :debit_note_details, :volume, :integer
  	change_column :invoice_details, :volume, :integer
  	change_column :note_details, :volume, :integer
  end
end
