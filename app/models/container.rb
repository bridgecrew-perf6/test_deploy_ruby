class Container < ActiveRecord::Base
  include UpcaseAttributes
  
  validates_presence_of :container_type, :on => :create
  has_many :shipping_instructions, :through => :si_containers
end
