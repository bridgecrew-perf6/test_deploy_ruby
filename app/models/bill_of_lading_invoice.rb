class BillOfLadingInvoice < ActiveRecord::Base
  attr_accessor :_destroy
  
  with_options touch: true do |assoc|
    # assoc.belongs_to :bill_of_lading
    assoc.belongs_to :shipping_instruction
  end

  with_options dependent: :destroy do |assoc|
    assoc.has_many :bill_of_lading_items, inverse_of: :bill_of_lading_invoice

    assoc.has_many :fixed_items, -> { where(item_type: 0) }, class_name: "BillOfLadingItem"
    assoc.has_many :active_items, -> { where(item_type: 1) }, class_name: "BillOfLadingItem"
    assoc.has_many :volume_items, -> { where(item_type: 2) }, class_name: "BillOfLadingItem"
    assoc.has_many :shipper_items, -> { where(item_type: 3) }, class_name: "BillOfLadingItem"
    assoc.has_many :carrier_items, -> { where(item_type: 4) }, class_name: "BillOfLadingItem"
  end

  accepts_nested_attributes_for :bill_of_lading_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true

  accepts_nested_attributes_for :fixed_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :active_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :volume_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :shipper_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :carrier_items, :reject_if => lambda { |a| a[:description].blank? }, :allow_destroy => true

  before_save :set_default_tick
  before_save :set_vat
  before_validation :set_vat

  def set_vat
    # value not equals with db set as manual input
    # if self.vat_1 == self.default_vat_1
    #  self.vat_1 = self.default_vat_1
    # end
    # value not equals with db set as manual input
    # if self.vat_10 == self.default_vat_10
    #  self.vat_10 = self.default_vat_10
    #end

    self.vat_1 = self.default_vat_1
    self.vat_10 = self.default_vat_10
    self.vat_11 = self.default_vat_11
    self.vat_1_1 = self.default_vat_1_1
    self.pph_23 = self.default_pph_23
  end

  def set_default_tick
    self.is_ai = true if !self.is_ai && !self.is_gi
  end

  def default_vat_10
    # total = 0
    # self.bill_of_lading_items.each do |item|
    #   total += item.total.to_f if item.add_vat_10
    # end

    # if self.is_ai
    #   (total / 11).round(2)
    # elsif self.is_gi
    #   (total * 0.1).round(2)
    # else
    #   0.to_f
    # end
    self.bill_of_lading_items.map{|p| p.vat_10 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def default_vat_1
    # total = 0
    # self.bill_of_lading_items.each do |item|
    #   total += item.total.to_f if item.add_vat_1
    # end

    # if self.is_ai
    #   (total / 101).round(2)
    # elsif self.is_gi
    #   (total * 0.01).round(2)
    # else
    #   0.to_f
    # end
    self.bill_of_lading_items.map{|p| p.vat_1 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def default_vat_11
    # total = 0
    # self.bill_of_lading_items.each do |item|
    #   total += item.total.to_f if item.add_vat_1
    # end

    # if self.is_ai
    #   (total / 101).round(2)
    # elsif self.is_gi
    #   (total * 0.01).round(2)
    # else
    #   0.to_f
    # end
    self.bill_of_lading_items.map{|p| p.vat_11 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def default_vat_1_1
    # total = 0
    # self.bill_of_lading_items.each do |item|
    #   total += item.total.to_f if item.add_vat_1
    # end

    # if self.is_ai
    #   (total / 101).round(2)
    # elsif self.is_gi
    #   (total * 0.01).round(2)
    # else
    #   0.to_f
    # end
    self.bill_of_lading_items.map{|p| p.vat_1_1 unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def default_pph_23
    # total = 0
    # self.bill_of_lading_items.each do |item|
    #   total += item.total_after_tax.to_f if item.add_pph_23
    # end
    # (total * (-0.02)).round(2)
    self.bill_of_lading_items.map{|p| p.pph_23 unless p.marked_for_destruction?}.sum(&:to_f)
  end
  
  def total_invoice_exclude_pph_23
    # total = 0
    # self.bill_of_lading_items.each do |item|
    #   total += item.total_after_tax.to_f
    # end

    # total = self.bill_of_lading_items.map{|p| p.total_after_tax unless p.marked_for_destruction?}.sum(&:to_f)
    # total += self.other.to_f
    # total += self.vat_10.to_f
    # total += self.vat_1.to_f

    # total.round(2)
    self.default_total_invoice_exclude_pph_23
  end

  def total_invoice
    # (self.total_invoice_exclude_pph_23.to_f + self.pph_23.to_f).round(2)
    self.default_total_invoice
  end

  def default_total_invoice_exclude_pph_23
    total = self.bill_of_lading_items.map{|p| p.total_after_tax unless p.marked_for_destruction?}.sum(&:to_f)
    total += self.other.to_f
    total += self.default_vat_10.to_f
    total += self.default_vat_1.to_f
    total += self.default_vat_11.to_f
    total += self.default_vat_1_1.to_f

    total.round(2)
  end

  def default_total_invoice
    (self.default_total_invoice_exclude_pph_23.to_f + self.default_pph_23.to_f).round(2)
  end

  def sum_total_after_tax
    self.bill_of_lading_items.map{|p| p.total_after_tax unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def sum_total
    self.bill_of_lading_items.map{|p| p.total unless p.marked_for_destruction?}.sum(&:to_f)
  end

  def invoice_total_invoice(currency)
    # unit_price = 0
    # if currency == "IDR"
    #   unit_price = self.sum_total_after_tax.to_f
    # elsif currency == "USD"
    #   rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
    #   unit_price = self.sum_total.to_f / rate
    # end
    rate = 1
    rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f if currency == "USD"
    unit_price = self.sum_total_after_tax.to_f / rate
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end

  def invoice_vat_10(currency)
    unit_price = self.bill_of_lading_items.map{|p| p.vat_10}.sum(&:to_f)
    if currency == "USD"
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      unit_price = unit_price / rate
    end
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end

  def invoice_vat_1(currency)
    unit_price = self.bill_of_lading_items.map{|p| p.vat_1}.sum(&:to_f)
    if currency == "USD"
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      unit_price = unit_price / rate
    end
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end

  def invoice_vat_11(currency)
    unit_price = self.bill_of_lading_items.map{|p| p.vat_11}.sum(&:to_f)
    if currency == "USD"
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      unit_price = unit_price / rate
    end
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end

  def invoice_vat_1_1(currency)
    unit_price = self.bill_of_lading_items.map{|p| p.vat_1_1}.sum(&:to_f)
    if currency == "USD"
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      unit_price = unit_price / rate
    end
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end

  def invoice_pph_23(currency)
    unit_price = self.bill_of_lading_items.map{|p| p.pph_23}.sum(&:to_f)
    if currency == "USD"
      rate = (self.rate.to_f == 0) ? 1 : self.rate.to_f
      unit_price = unit_price / rate
    end
    ((unit_price.is_a?(Float) || unit_price.is_a?(BigDecimal)) && unit_price.nan?) ? 0 : unit_price.round(2)
  end
end
