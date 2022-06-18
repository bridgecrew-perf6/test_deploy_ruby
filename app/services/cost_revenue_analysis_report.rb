class CostRevenueAnalysisReport
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :format, :filter_by, :yearly, :monthly, :from, :to

  validates_presence_of :format, :filter_by
  # validates_presence_of :yearly, :monthly, :from, :to
  validates_inclusion_of :format, in: ["pdf", "xls"]
  validates_inclusion_of :filter_by, in: ["yearly", "monthly", "date", "all"]

  def filename
    tmp = "C&R Analysis List"
    tmp += " #{self.yearly}" if self.filter_by == "yearly"
    tmp += " #{self.monthly}" if self.filter_by == "monthly"
    if self.filter_by == "date"
      tmp += " From: #{self.from} " unless self.from.blank?
      tmp += " To: #{self.to} " unless self.from.blank?
    end
    tmp.upcase
  end

  def title
    tmp = "C&R Analysis List"
    tmp += " #{self.yearly}" if self.filter_by == "yearly"
    tmp += " #{self.monthly}" if self.filter_by == "monthly"
    if self.filter_by == "date"
      tmp += " From: #{self.from} " unless self.from.blank?
      tmp += " To: #{self.to} " unless self.from.blank?
    end
    tmp.upcase
  end

  # def populate_data
  #   begin
  #     case self.filter_by
  #     when "yearly"
  #       year = Constant.years_range.include?(self.yearly) ? self.yearly : Date.today.year
  #       cost_revenues = CostRevenue.includes(:cost_revenue_items, :shipping_instruction, :shipper, :consignee, cr_containers: [ :container ])
  #       .where("cost_revenues.ibl_ref LIKE ?", "IBL#{year.to_s[2..3]}%")
  #       # .where("YEAR(cost_revenues.etd_date) = ?", year)
  #       # .order("shipping_instructions.si_no ASC")
  #     when "monthly"
  #       date = Date.parse(self.monthly)
  #       cost_revenues = CostRevenue.includes(:cost_revenue_items, :shipping_instruction, :shipper, :consignee, cr_containers: [ :container ])
  #       .where("cost_revenues.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month)
  #       # .order("shipping_instructions.si_no ASC")
  #     when "date"
  #       from = Date.parse(self.from)
  #       to = Date.parse(self.to)
  #       cost_revenues = CostRevenue.includes(:cost_revenue_items, :shipping_instruction, :shipper, :consignee, cr_containers: [ :container ])
  #       .where("cost_revenues.etd_date BETWEEN ? AND ?", from, to)
  #       # .order("shipping_instructions.si_no ASC")
  #     else
  #       raise
  #     end
  #   rescue
  #     # cost_revenues = CostRevenue.includes(:cost_revenue_items)
  #   end
  # end

  def populate_data
    begin
      case self.filter_by
      # when "yearly"
      #   year = Constant.years_range.include?(self.yearly) ? self.yearly : Date.today.year
      #   shipping_instructions = ShippingInstruction.includes(cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("cost_revenues.ibl_ref LIKE ?", "IBL#{year.to_s[2..3]}%").references(:cost_revenue)
      # when "monthly"
      #   date = Date.parse(self.monthly)
      #   shipping_instructions = ShippingInstruction.includes(cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("cost_revenues.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month).references(:cost_revenue)
      #   # .order("shipping_instructions.si_no ASC")
      # when "date"
      #   from = Date.parse(self.from)
      #   to = Date.parse(self.to)
      #   shipping_instructions = ShippingInstruction.includes(cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("cost_revenues.etd_date BETWEEN ? AND ?", from, to).references(:cost_revenue)
      #   # .order("shipping_instructions.si_no ASC")
      
      when "yearly"
        year = Constant.years_range.include?(self.yearly.to_i) ? self.yearly : Date.today.year
        # shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{year.to_s[2..3]}%").references(:cost_revenue)
        shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{year.to_s[2..3]}%")
      
        shipping_instructions = shipping_instructions.where(is_shadow: false)
      
      when "monthly"
        date = Date.parse(self.monthly)
        # shipping_instructions = ShippingInstruction.includes(cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("cost_revenues.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month).references(:cost_revenue)
        # shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{date.year.to_s[2..3]}%").references(:cost_revenue)
        shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{date.year.to_s[2..3]}%")
        # shipping_instructions = ShippingInstruction.where("shipping_instructions.si_no LIKE ?", "IBL161041")
        
        shipping_instructions = shipping_instructions.where(is_shadow: false)
        
        # shipping_instructions = shipping_instructions.where("cost_revenues.etd_date BETWEEN ? AND ?", date.at_beginning_of_month, date.end_of_month).references(:cost_revenue)
        shipping_instructions = shipping_instructions.to_a.delete_if{|a| a.first_etd_date.blank?}
        shipping_instructions = shipping_instructions.delete_if{|a| !(a.first_etd_date >= date.at_beginning_of_month)}
        shipping_instructions = shipping_instructions.delete_if{|a| !(a.first_etd_date <= date.end_of_month)}
        # .order("shipping_instructions.si_no ASC")
      when "date"
        from = Date.parse(self.from)
        to = Date.parse(self.to)
        # shipping_instructions = ShippingInstruction.includes(cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("cost_revenues.etd_date BETWEEN ? AND ?", from, to).references(:cost_revenue)
        # .order("shipping_instructions.si_no ASC")
        if from.year == to.year
          # shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{from.year.to_s[2..3]}%").references(:cost_revenue)
          shipping_instructions = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{from.year.to_s[2..3]}%")
          
          shipping_instructions = shipping_instructions.where(is_shadow: false)
        
          shipping_instructions = shipping_instructions.to_a.delete_if{|a| a.first_etd_date.blank?}
          shipping_instructions = shipping_instructions.delete_if{|a| !(a.first_etd_date >= from)}
          shipping_instructions = shipping_instructions.delete_if{|a| !(a.first_etd_date <= to)}
        else
          # shipping_instructions1 = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{from.year.to_s[2..3]}%").references(:cost_revenue)
          shipping_instructions1 = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{from.year.to_s[2..3]}%")
          
          shipping_instructions1 = shipping_instructions1.where(is_shadow: false)
        
          shipping_instructions1 = shipping_instructions1.to_a.delete_if{|a| a.first_etd_date.blank?}
          shipping_instructions1 = shipping_instructions1.delete_if{|a| !(a.first_etd_date >= from)}
          # shipping_instructions2 = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{to.year.to_s[2..3]}%").references(:cost_revenue)
          shipping_instructions2 = ShippingInstruction.includes(:shipper, :consignee, :vessels, si_containers: [ :container ], cost_revenue: [ :shipper, :consignee, :cost_revenue_items, cr_containers: [ :container ] ]).where("shipping_instructions.si_no LIKE ?", "IBL#{to.year.to_s[2..3]}%")
          
          shipping_instructions2 = shipping_instructions2.where(is_shadow: false)
        
          shipping_instructions2 = shipping_instructions2.to_a.delete_if{|a| a.first_etd_date.blank?}
          shipping_instructions2 = shipping_instructions2.delete_if{|a| !(a.first_etd_date <= to)}
          shipping_instructions = shipping_instructions1 + shipping_instructions2
        end        
      else
        raise
      end
    rescue
      # cost_revenues = CostRevenue.includes(:cost_revenue_items)
    end
  end

  def template
    "cost_revenue_analysis_report"
  end
end
