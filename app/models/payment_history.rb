class PaymentHistory < ActiveRecord::Base
  include UpcaseAttributes

  with_options touch: true do |assoc|
    assoc.belongs_to :payment
    assoc.belongs_to :invoice
  end
end
