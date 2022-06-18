class CarrierItem < ActiveRecord::Base
  include UpcaseAttributes

  attr_accessor :_destroy
  belongs_to :carrier, touch: true
end
