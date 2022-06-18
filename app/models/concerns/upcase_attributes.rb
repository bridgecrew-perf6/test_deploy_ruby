module UpcaseAttributes
  extend ActiveSupport::Concern

  included do
    before_save :uppercase_fields
  end

  def uppercase_fields
    self.attributes.each do |key, value|
      self.attributes[key] = value.to_s.upcase!
    end
  end
end