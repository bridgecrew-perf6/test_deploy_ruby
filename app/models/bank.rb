class Bank < ActiveRecord::Base
  include UpcaseAttributes

	has_many :payments
	
  validates_presence_of :bank_name, :bank_address, :acc_name, :acc_no, presence: true
end
