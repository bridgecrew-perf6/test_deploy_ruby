class CrContainer < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
    assoc.belongs_to :container
    assoc.belongs_to :cost_revenue
  end
  
  accepts_nested_attributes_for :container
end
