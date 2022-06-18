class CustomField < ActiveRecord::Base
  include UpcaseAttributes

	default_scope { order("field_key ASC") }
	belongs_to :field, :polymorphic => true
end
