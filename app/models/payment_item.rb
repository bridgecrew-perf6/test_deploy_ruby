class PaymentItem < ActiveRecord::Base
  include UpcaseAttributes

  enum item_type: [ :fixed, :active, :volume, :shipper, :carrier ]

  delegate :rate, :vat_10, :vat_1, :pph_23, to: :payment_invoice, allow_nil: true
  
  attr_accessor :_destroy
  belongs_to :payment_invoice, touch: true, inverse_of: :payment_items

  def total
    # return if self._destroy == 1
    if self.amount_usd.to_f != 0
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      (self.volume.to_f * self.amount_usd.to_f * rate).round(2)
    elsif self.amount_idr.to_f != 0
      (self.volume.to_f * self.amount_idr.to_f).round(2)
    end
  end

  def total_after_tax
    # return if self._destroy == 1
    # if self.total.to_f != 0
    #   if self.is_ai
    #     (self.total.to_f - self.vat_10.to_f - self.vat_1.to_f).round(2)
    #   elsif self.is_gi
    #     self.total.to_f
    #   end
    # end
    self.total.to_f unless self.total.to_f == 0
  end

  def vat_10
    self.add_vat_10 ? (self.total.to_f*0.1).round(2) : 0
  end

  def vat_1
    self.add_vat_1 ? (self.total.to_f*0.01).round(2) : 0
  end

  def pph_23
    self.add_pph_23 ? (self.total.to_f*(-0.02)).round(2) : 0
  end
end
