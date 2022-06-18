class CreatePaymentHistories < ActiveRecord::Migration
  def change
    create_table :payment_histories do |t|
      t.belongs_to :payment, index: true
      t.belongs_to :invoice, index: true
    end
  end
end
