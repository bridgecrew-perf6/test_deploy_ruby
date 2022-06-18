class Consignee < ActiveRecord::Base
  include UpcaseAttributes

  # scope :with_custom_fields, -> { includes(:custom_fields).order(:company_name) }
  # scope :with_custom_fields, -> { where(is_deleted: false).order(:company_name) }
  scope :search, -> { where(is_deleted: false).order(:company_name) }
  scope :with_custom_fields, -> { order(:company_name) }
  # default_scope -> { where(is_deleted: false) }

  attr_accessor :country_name

  validates_presence_of :company_name, :credit_term, :address
  validates_numericality_of :credit_term

  belongs_to :country, touch: true

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
    full_address = ""
    full_address += self.address
    # full_address += "<br/>#{self.city}"
    # full_address += ", #{self.zipcode}" unless self.zipcode.nil? || self.zipcode.blank?
    # full_address += ", #{self.country.name.upcase}"
    # full_address.html_safe
  end

  def contact_person
    contact_person = ""
    contact_person += "<strong>Name :</strong> #{self.contact_name}<br/>" unless self.contact_name.nil? || self.contact_name.blank?
    contact_person += "<strong>Phone :</strong> #{self.phone}<br/>" unless self.phone.nil? || self.phone.blank?
    contact_person += "<strong>C.Phone :</strong> #{self.cellphone}<br/>" unless self.cellphone.nil? || self.cellphone.blank?
    contact_person += "<strong>Email : </strong> #{self.email_address}<br/>" unless self.email_address.nil? || self.email_address.blank?
    contact_person.html_safe
  end

  def country_name #Getter Country Name
    self.country.name unless self.country_id.nil?
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

  private
  def set_default_attributes
    self.credit_term = 0 if self.credit_term.nil?
  end
end
