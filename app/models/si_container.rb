class SiContainer < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
    assoc.belongs_to :container
    assoc.belongs_to :shipping_instruction
  end

  accepts_nested_attributes_for :container
end
