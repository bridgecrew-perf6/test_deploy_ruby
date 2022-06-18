class Shipper < ActiveRecord::Base
  include UpcaseAttributes

  has_many :shipper_items, :dependent => :destroy
  accepts_nested_attributes_for :shipper_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true

  # scope :with_custom_fields, -> { references(:custom_fields).includes(:custom_fields).where(is_deleted: false).order(:company_name) }
  scope :search, -> { where(is_deleted: false).order(:company_name) }
  scope :with_custom_fields, -> { order(:company_name) }
	# default_scope -> { where(is_deleted: false) }
	
	validates_presence_of :company_name, :credit_term, :bl_address
	validates_numericality_of :credit_term

	with_options dependent: :nullify do |assoc|
		assoc.has_many :shipping_instructions
		assoc.has_many :shipping_instruction_histories
		assoc.has_many :bill_of_ladings
		assoc.has_many :bill_of_lading_histories
	end

	has_many :custom_fields, :as => :field, :dependent => :destroy
	accepts_nested_attributes_for :custom_fields, :reject_if => lambda { |a| a[:field_key].blank? or a[:field_value].blank? }, :allow_destroy => true

  after_initialize :set_default_attributes

	def full_address
		unless self.new_record?
			#address_custom_fields = self.custom_fields.where(:field_key => "address") unless self.new_record?
			#full_address = ""
			#fuld_address = address_custom_fields.first.field_value if address_custom_fields.any?
			self.bl_address
		end
	end

	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << ["ID", "Shipper Name", "Reference", "Credit Term", "Notes", "Address 1", "Address 2", "Address 3", "Address 4", "Address 5", "Address 6", "Email 1", "Email 2", "Email 3", "Email 4", "Email 5", "Email 6",
				"Phone 1", "Phone 2", "Phone 3", "Phone 4", "Phone 5", "Phone 6", "URL 1", "URL 2", "URL 3", "Custom Field 1", "Custom Field 2", "Custom Field 3", "Custom Field 4", "Custom Field 5",
				"Custom Field 6", "Custom Field 7", "Custom Field 8", "Custom Field 9", "Custom Field 10"]
			all.each do |shipper|
				item = Array.new
				item.push(shipper.id, shipper.company_name, shipper.reference, shipper.credit_term, shipper.notes)

				address = shipper.custom_fields.where(:field_key => "address").first(6).each do |a| item.push(a.field_value) end
				(6 - address.count).times do |n| item.push("") end

				email = shipper.custom_fields.where(:field_key => "email").first(6).each do |e| item.push(e.field_value) end
				(6 - email.count).times do |n| item.push("") end

				phone = shipper.custom_fields.where(:field_key => "phone").first(6) .each do |p| item.push(p.field_value) end
				(6 - phone.count).times do |n| item.push("") end

				url = shipper.custom_fields.where(:field_key => "url").first(3).each do |u| item.push(u.field_value) end
				(3 - url.count).times do |n| item.push("") end

				custom = shipper.custom_fields.where(:field_key => "custom").first(10).each do |c| item.push(c.field_value) end
				(10 - custom.count).times do |n| item.push("") end

				csv << item
			end
	    end
	end

	def custom_attribute(key)
		custom_attr = self.custom_fields.where(field_key: key).first
		# unless custom_attr.nil?
		# 	custom_attr.field_value
		# end
		custom_attr.blank? ? "" : custom_attr.field_value
  end

  def set_deleted
    update(is_deleted: true)
  end

  def set_enabled
    update(is_deleted: false)
  end

  def self.get_shipper_charges(number)
    shipper = find(number)

    if shipper.nil?
      @get_shipper_charges = {success: false, message: "Shipper Not Listed"}
    else
      charges = []

      @get_shipper_charges = begin
        unless shipper.shipper_items.blank?
          shipper.shipper_items.each do |item|
            charges << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, item_type: 'shipper' }
          end
          {success: true, charges: charges}
        else
          # charges << { description: 'PEB', item_type: 'shipper' }
          # charges << { description: 'Fiat PEB', item_type: 'shipper' }
          # charges << { description: 'COO', item_type: 'shipper' }
          # charges << { description: 'Trucking', item_type: 'shipper' }
          # charges << { description: 'Fumigation', item_type: 'shipper' }
          {success: false, message: "Shipper Charges Not Listed"}
        end
      end
    end

    @get_shipper_charges
  end

  private
  def set_default_attributes
    self.credit_term = 0 if self.credit_term.nil?
  end
end
