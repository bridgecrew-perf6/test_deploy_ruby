class Tracking < ActiveRecord::Base
  include UpcaseAttributes

  belongs_to :bill_of_lading, touch: true
end
