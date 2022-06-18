class CreateNotePayments < ActiveRecord::Migration
  def change
    create_table :note_payments do |t|
    	t.belongs_to :note, index: true
		t.date :payment_date
		t.decimal :amount_paid, :precision => 13, :scale => 2
		t.decimal :rounding, :precision => 13, :scale => 2
		t.decimal :bank_charge, :precision => 13, :scale => 2
		t.decimal :discount, :precision => 13, :scale => 2
		t.decimal :short_paid, :precision => 13, :scale => 2
		t.decimal :deposit, :precision => 13, :scale => 2
		t.text :note
    end
  end
end
