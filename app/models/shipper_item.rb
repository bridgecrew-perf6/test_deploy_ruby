class ShipperItem < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :_destroy
  belongs_to :shipper, touch: true
end
