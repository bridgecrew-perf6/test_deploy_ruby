class CarrierBank < ActiveRecord::Base
  include UpcaseAttributes

	# default_scope -> { where(is_deleted: false) }
	# default_scope -> { includes(:carrier).where(is_deleted: false).where("carriers.is_deleted = false").references(:carrier) }
	scope :with_custom_fields, -> { includes(:carrier).order("carriers.name ASC").references(:carrier) }
  
  belongs_to :carrier, touch: true
	has_many :payments, :dependent => :destroy
	validates_presence_of :carrier_id, :bank_name, :acc_name, :acc_no, :currency
	validates_presence_of :swift_code, :if => lambda { |args| args.currency == "USD" }
	
	def carrier_bank_name
		[self.carrier.name, self.bank_name, self.currency].join(" ")
  end

  def set_deleted
    update(is_deleted: true)
  end

  def set_enabled
    update(is_deleted: false)
  end

  def self.search(query)
    # @search = query ? CarrierBank.where(currency: query) : CarrierBank.all
    # @search = CarrierBank.all
    
    @search = CarrierBank.includes(:carrier).where(is_deleted: false).where("carriers.is_deleted = false").references(:carrier)
    # @search = CarrierBank.includes(:carrier).order("carriers.name ASC").references(:carrier)
    @search = @search.where(currency: query[:code]) unless query[:code].blank?
    @search = @search.where(carrier_id: query[:carrier_id]) unless query[:carrier_id].blank?
    @search.includes(:carrier).order("carriers.name")
  end
end
