module CostRevenuesHelper
	def sell_usd(cr)
    str = []
    amount = cr.cost_revenue_items.where(description: 'LCL').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/LCL" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/20'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/40'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.selling_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/HQ" unless amount == 0

    str
	end

  def sell_idr(cr)
    str = []
    amount = cr.cost_revenue_items.where(description: 'LCL').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/LCL" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/20'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/40'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.selling_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/HQ" unless amount == 0
    
    str
  end

  def cost_usd(cr)
    str = []
    amount = cr.cost_revenue_items.where(description: 'LCL').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/LCL" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/20'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/40'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.buying_usd}.sum(&:to_f)
    str.push "#{money_format(amount)}/HQ" unless amount == 0
    
    str
  end

  def cost_idr(cr)
    str = []
    amount = cr.cost_revenue_items.where(description: 'LCL').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/LCL" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 20\'').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/20'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40\'').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/40'" unless amount == 0
    amount = cr.cost_revenue_items.where(description: 'OF 40HC').map{|p| p.buying_idr}.sum(&:to_f)
    str.push "#{money_format(amount)}/HQ" unless amount == 0
    
    str
  end

  def sell_description(row)
    str = []
    cr = row.cost_revenue
    unless cr.blank?
      cr.cost_revenue_items.each do |item|
        volume = (item.description == "LCL") ? lcl_format(item.selling_volume) : money_format(item.selling_volume)
        if item.selling_usd.to_f > 0
          amount = "#{money_format item.selling_usd} USD"
        elsif item.selling_idr.to_f > 0     
          amount = "#{money_format item.selling_idr} IDR"
        else
          amount = 0
        end
        str.push "#{item.description} (#{volume}X#{amount})" if item.selling_volume.to_f > 0
      end
    end
    str.join(" ")
  end

  def cost_description(row)
    str = []
    cr = row.cost_revenue
    unless cr.blank?
      cr.cost_revenue_items.each do |item|
        volume = (item.description == "LCL") ? lcl_format(item.buying_volume) : money_format(item.buying_volume)
        if item.buying_usd.to_f > 0
          amount = "#{money_format item.buying_usd} USD"
        elsif item.buying_idr.to_f > 0     
          amount = "#{money_format item.buying_idr} IDR"
        else
          amount = 0
        end
        str.push "#{item.description} (#{volume}X#{amount})" if item.buying_volume.to_f > 0
      end
    end
    str.join(" ")
  end
end
