class Carrier < ActiveRecord::Base
  include UpcaseAttributes

  has_many :carrier_items, :dependent => :destroy
  accepts_nested_attributes_for :carrier_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true

  # scope :with_custom_fields, -> { includes(:custom_fields).order(:name) }
  # scope :with_custom_fields, -> { where(is_deleted: false).order(:name) }
  scope :search, -> { where(is_deleted: false).order(:name) }
  scope :with_custom_fields, -> { order(:name) }
  # default_scope -> { where(is_deleted: false) }

  validates_presence_of :name
  validates_numericality_of :credit_term

  with_options dependent: :destroy do |assoc|
    assoc.has_many :custom_fields, :as => :field
    assoc.has_many :carrier_banks
  end
  accepts_nested_attributes_for :custom_fields, :reject_if => lambda { |a| a[:field_key].blank? or a[:field_value].blank? }, :allow_destroy => true

  after_initialize :set_default_attributes

  # TODO: this should be presenter
  def full_address
    full_address = ""
    full_address += self.address unless self.address.nil?
    # full_address += "<br/>#{self.city}"
    # full_address += ", #{self.zipcode}" unless self.zipcode.nil? || self.zipcode.blank?
    # full_address += ", #{self.country.name.upcase}"
    # full_address.html_safe
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["ID", "Carrier Name", "Notes", "Address 1", "Address 2", "Address 3", "Address 4", "Address 5", "Address 6", "Email 1", "Email 2", "Email 3", "Email 4", "Email 5", "Email 6",
              "Phone 1", "Phone 2", "Phone 3", "Phone 4", "Phone 5", "Phone 6", "URL 1", "URL 2", "URL 3", "Custom Field 1", "Custom Field 2", "Custom Field 3", "Custom Field 4", "Custom Field 5",
              "Custom Field 6", "Custom Field 7", "Custom Field 8", "Custom Field 9", "Custom Field 10"]
      all.each do |carrier|
        item = Array.new
        item.push(carrier.id, carrier.name, carrier.notes)

        address = carrier.custom_fields.where(:field_key => "address").first(6).each do |a|
          item.push(a.field_value)
        end
        (6 - address.count).times do |n|
          item.push("")
        end

        email = carrier.custom_fields.where(:field_key => "email").first(6).each do |e|
          item.push(e.field_value)
        end
        (6 - email.count).times do |n|
          item.push("")
        end

        phone = carrier.custom_fields.where(:field_key => "phone").first(6).each do |p|
          item.push(p.field_value)
        end
        (6 - phone.count).times do |n|
          item.push("")
        end

        url = carrier.custom_fields.where(:field_key => "url").first(3).each do |u|
          item.push(u.field_value)
        end
        (3 - url.count).times do |n|
          item.push("")
        end

        custom = carrier.custom_fields.where(:field_key => "custom").first(10).each do |c|
          item.push(c.field_value)
        end
        (10 - custom.count).times do |n|
          item.push("")
        end

        csv << item
      end
    end
  end

  def custom_attribute(key)
    custom_attr = self.custom_fields.where(field_key: key).first
    # unless custom_attr.nil?
    #   custom_attr.field_value
    # end
    custom_attr.blank? ? "" : custom_attr.field_value
  end

  def set_deleted
    update(is_deleted: true)
  end

  def set_enabled
    update(is_deleted: false)
  end

  def self.get_carrier_charges(number)
    # carrier = find_by(name: number)
    carrier = find(number)

    if carrier.nil?
      @get_carrier_charges = {success: false, message: "Carrier Not Listed"}
    else
      charges = []

      @get_carrier_charges = begin
        unless carrier.carrier_items.blank?
          carrier.carrier_items.each do |item|
            charges << { description: item.description, amount_usd: item.amount_usd, amount_idr: item.amount_idr, item_type: 'carrier' }
          end
          {success: true, charges: charges}
        else
          # charges << { description: 'Doc', item_type: 'carrier' }
          # charges << { description: 'Adm', item_type: 'carrier' }
          # charges << { description: 'Seal', item_type: 'carrier' }
          # charges << { description: 'AMS/ENS', item_type: 'carrier' }
          # charges << { description: 'Telex', item_type: 'carrier' }
          # charges << { description: 'Switch', item_type: 'carrier' }
          # charges << { description: 'Certificate', item_type: 'carrier' }
          # charges << { description: 'SIA', item_type: 'carrier' }
          {success: false, message: "Carrier Charges Not Listed"}
        end
      end
    end

    @get_carrier_charges
  end

    private
    def set_default_attributes
      self.credit_term = 0 if self.credit_term.nil?
  end
end