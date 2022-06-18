class Agent < ActiveRecord::Base
  include UpcaseAttributes

  # scope :with_custom_fields, -> { includes(:custom_fields).order(:name) }
  # scope :with_custom_fields, -> { where(is_deleted: false).order(:name) }
  scope :search, -> { where(is_deleted: false).order(:name) }
  scope :with_custom_fields, -> { order(:name) }
  # default_scope -> { where(is_deleted: false) }
	
	validates_presence_of :name, :credit_term, :address
	validates_numericality_of :credit_term

	has_many :custom_fields, :as => :field, :dependent => :destroy
	accepts_nested_attributes_for :custom_fields, :reject_if => lambda { |a| a[:field_key].blank? or a[:field_value].blank? },
                                :allow_destroy => true

  after_initialize :set_default_attributes
	
  # TODO: This should be presenter
	def full_address
		full_address = ""
		full_address += self.address unless self.address.nil?
		# full_address += "<br/>#{self.city}"
		# full_address += ", #{self.zipcode}" unless self.zipcode.nil? || self.zipcode.blank?
		# full_address += ", #{self.country.name.upcase}"
		# full_address.html_safe
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

  # def self.search(query)
  #   @search = self.where(is_deleted: false)
  #   @search.order(:name)
  # end

  private
  def set_default_attributes
    self.credit_term = 0 if self.credit_term.nil?
  end
end
