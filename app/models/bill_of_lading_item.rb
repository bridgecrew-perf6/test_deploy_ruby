class BillOfLadingItem < ActiveRecord::Base
  include UpcaseAttributes

  enum item_type: [ :fixed, :active, :volume, :shipper, :carrier ]

  attr_accessor :_destroy
  # belongs_to :bill_of_lading, touch: true
  belongs_to :bill_of_lading_invoice, touch: true, inverse_of: :bill_of_lading_items

  delegate :rate, :vat_10, :vat_1, :vat_11, :vat_1_1, :pph_23, :is_tick_all, :is_ai, :is_gi, to: :bill_of_lading_invoice, allow_nil: true

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
    if self.total.to_f != 0
      if self.is_gi
        self.total.to_f
      else
        # (self.total.to_f - self.vat_10.to_f - self.vat_1.to_f).round(2)
        # total = self.total.to_f
        # total -= self.total.to_f/11 if self.add_vat_10
        # total -= self.total.to_f/101 if self.add_vat_1
        total = self.total.to_f - self.vat_10.to_f - self.vat_1.to_f - self.vat_11.to_f - self.vat_1_1.to_f
        total.round(2)
      end
    end
  end

  def vat_10
    # return if self._destroy == 1
    if self.add_vat_10
      self.is_gi ? (self.total.to_f*0.1).round(2) : (self.total.to_f/11).round(2)
    end
  end

  def vat_1
    # return if self._destroy == 1
    if self.add_vat_1
      self.is_gi ? (self.total.to_f*0.01).round(2) : (self.total.to_f/101).round(2)
    end
  end

  def vat_11
    # return if self._destroy == 1
    if self.add_vat_11
      #self.is_gi ? (self.total.to_f*0.11).round(2) : (self.total.to_f/11.1).round(2)
      self.is_gi ? (self.total.to_f*0.11).round(2) : (self.total.to_f/111*11).round(2)
    end
  end

  def vat_1_1
    # return if self._destroy == 1
    if self.add_vat_1_1
      #self.is_gi ? (self.total.to_f*0.011).round(2) : (self.total.to_f/101.1).round(2)
      self.is_gi ? (self.total.to_f*0.011).round(2) : (self.total.to_f*1.1/101.1).round(2)
    end
  end

  def pph_23
    # return if self._destroy == 1
    self.add_pph_23 ? (self.total_after_tax.to_f*(-0.02)).round(2) : 0
  end

  def amount
    unit_price = self.total_after_tax.to_f / self.volume.to_f
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end

  # def amount(currency)
  #   unit_price = 0
  #   if currency == "IDR"
  #     unit_price = self.total_after_tax.to_f / self.volume.to_f
  #   elsif currency == "USD"
  #     rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
  #     unit_price = (self.total.to_f / self.volume.to_f) / rate
  #   end
  #   ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  # end

  def invoice_amount(currency)
    # unit_price = 0
    # if currency == "IDR"
    #   unit_price = self.total_after_tax.to_f / self.volume.to_f
    # elsif currency == "USD"
    #   rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
    #   unit_price = (self.total.to_f / self.volume.to_f) / rate
    # end
    rate = 1
    rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f if currency == "USD"
    unit_price = (self.total_after_tax.to_f / self.volume.to_f).round(2) / rate

    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end
end
