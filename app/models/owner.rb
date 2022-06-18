class Owner < ActiveRecord::Base
  include UpcaseAttributes

  # scope :with_custom_fields, -> { where(is_deleted: false).order(:name) }
  scope :search, -> { where(is_deleted: false).order(:name) }
  scope :with_custom_fields, -> { order(:name) }
	
	validates_presence_of :name

	has_many :custom_fields, :as => :field, :dependent => :destroy
	accepts_nested_attributes_for :custom_fields, :reject_if => lambda { |a| a[:field_key].blank? or a[:field_value].blank? },
                                :allow_destroy => true
	
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
end
