module ApplicationHelper
	def current_class?(header_menu)
		case header_menu
		when "manages"
			return 'in' if (current_page?(users_path) || current_page?(carriers_path) || current_page?(consignees_path) || current_page?(shippers_path) ||
				current_page?(carrier_banks_path))
		when 'reports'
			return 'in' if (current_page?(cost_revenues_path) || current_page?(control_center_path) || current_page?(outstanding_bonshipment_path) ||
				current_page?(report_tracking_path))
		when 'shipments'
			return 'in' if request.original_fullpath =~ /^\/shipment_trackings/
		when 'payments'
			return 'in' if request.original_fullpath =~ /^\/payments/
		when 'instructions'
			return 'in' if request.original_fullpath =~ /^\/shipping_instructions/
		when 'ladings'
			return 'in' if request.original_fullpath =~ /^\/bill_of_ladings/
		when 'cra'
			return 'in' if request.original_fullpath =~ /^\/cost_revenues/
		when 'invoices'
			return 'in' if request.original_fullpath =~ /^\/list-inv-dbn/
		else
			''
		end
	end

	def local_date(date_str)
		date_str.to_time.strftime('%d %b %Y %H:%M:%S')
	end

	def si_date_format(date_str)
		date_str.to_time.strftime('%d-%b-%Y') unless date_str.nil?
	end

	def fu_date_format(date_str)
		date_str.to_time.strftime('%d %b %Y') unless date_str.nil?
	end
  
  def abbr_date_format(date_str)
    date_str.to_time.strftime('%d %b %Y') unless date_str.nil?
  end

	def payment_date(date_str)
		date_str.to_time.strftime('%d %b %Y') unless date_str.nil?
	end

	def normal_date_format(date_str)
		date_str.to_time.strftime('%d %B %Y') unless date_str.nil?
	end

	def datebase_date(date_str)
		date_str.to_time.strftime('%Y-%m-%d') unless date_str.nil?
	end

	def paid_month_date_format(date_str)
		date_str.to_time.strftime('%b %Y') unless date_str.nil?
	end

	def assets_path(asset)
		if request.fullpath.include? ".pdf"
	      "#{Rails.root.join('app', 'assets',"images", asset)}"
	    else
	    	"/assets/#{asset}"
	    end
	end

	# def link_to_remove_fields(name, f)
	# 	f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
	# end

	# def link_to_add_fields(name, f, association)
	#   new_object = f.object.class.reflect_on_association(association).klass.new
	#   fields = fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
	#     safe_concat(render(association.to_s.singularize + "_fields", :f => builder))
	#   end
	#   link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
	# end

	def terbilang (bilangan)
		bilangan = bilangan.abs
		angka = ["", "Satu", "Dua", "Tiga", "Empat", "Lima", "Enam", "Tujuh", "Delapan", "Sembilan", "Sepuluh", "Sebelas"]

		temp = ""

		if bilangan < 12
			temp = " " + angka[bilangan]
		elsif bilangan < 20
			temp = terbilang(bilangan - 10) + " belas"
		elsif bilangan < 100
			temp = terbilang(bilangan / 10) + " puluh" + terbilang(bilangan % 10)
		elsif bilangan < 200
			temp = " seratus" + terbilang(bilangan - 100)
		elsif bilangan < 1000
			temp = terbilang(bilangan / 100) + " ratus" + terbilang(bilangan % 100)
		elsif bilangan < 2000
			temp = " seribu" + terbilang(bilangan - 1000)
		elsif bilangan < 1000000
 			temp = terbilang(bilangan / 1000) + " ribu" + terbilang(bilangan % 1000)
 		elsif bilangan < 1000000000
 			temp = terbilang(bilangan / 1000000) + " juta" + terbilang(bilangan % 1000000)
		end

		return temp
	end

	def number_format(number)
		number = number.gsub(",", "").to_f if number.to_s.include? ','
		number.to_f unless number.blank? || number.to_f == 0
	end

	def money_format(number)
		unless number.blank?
			number = number_format(number)
			# number_with_delimiter(number_with_precision(number, precision: 2)) unless number.to_f == 0
			unless number.to_f == 0
        # unless number.to_i == number
			  #		number_with_delimiter(number_with_precision(number, precision: 2))
				# else
				# 	number_with_delimiter(number.to_i)
				# end
        negative = false
        if number < 0
          negative = true
          number = number * (-1)
        end
        str = ""
        unless number.to_i == number
          str = number_with_delimiter(number_with_precision(number, precision: 2))
        else
          str = number_with_delimiter(number.to_i)
        end
        if negative
          "(#{str})"
        else
          str
        end
			end
		end
	end

  def volume_format(number)
    unless number.blank?
      number = number_format(number)
      # number_with_delimiter(number_with_precision(number, precision: 2)) unless number.to_f == 0
      unless number.to_f == 0
        unless number.to_i == number
          number_with_delimiter(number_with_precision(number, precision: 2))
        else
          number_with_delimiter(number.to_i)
        end
      end
    end
  end

	def lcl_format(number)
		unless number.blank?
			number = number_format(number)
			# number_with_delimiter(number_with_precision(number, precision: 2)) unless number.to_f == 0
			unless number.to_f == 0
		 		number_with_delimiter(number_with_precision(number, precision: 3))
			end
		end
	end

	def money_with_currency_format(number, currency)
		# "#{money_format(number)} #{currency}" unless number.blank? || number.to_f == 0
	unless number.blank? || number.to_f == 0
      number = number_format(number)
      negative = false
      if number < 0
        negative = true
        number = number * (-1)
      end
      str = money_format(number)
      str = str.gsub(/[()]/, "") if str.to_s.include? '('
      if negative
        "(#{str} #{currency})"
      else
        "#{str} #{currency}"
      end
    end
  end

	def transit_time_format(number)
		pluralize(number.to_i, 'day') unless number.blank?
	end

	def datepicker_format(date_str)
		date_str.to_time.strftime('%m/%d/%Y') unless date_str.blank?
	end

	def monthly_format(date_str)
		# date_str.to_time.strftime('%m') unless date_str.nil?
		date_str.to_time.strftime('%B %Y') unless date_str.nil?
		# date_str.to_time.strftime('%B') unless date_str.nil?
	end

	def nl2br(text)
		text.to_s.gsub(/(?:\n\r?|\r\n?)/, '<br>')
	end

	def collapse_note(str)
		"<div class='wrap collapsed'>#{simple_format str}</div><a class='adjust' href='#'>+ More</a>".html_safe unless str.blank?
	end

  def money_cra_format(number)
    unless number.blank?
      number = number_format(number)
      unless number.to_f == 0
        unless number.to_i == number
          number_with_precision(number, precision: 2)
        else
          number.to_i
        end
      end
    end
  end

  def money_with_decimal_format(number)
		number = number_format(number)
		number_with_delimiter(number_with_precision(number, precision: 2))
	end

  def volume_with_decimal_format(number)
    number = number_format(number)
    number_with_delimiter(number_with_precision(number, precision: 3))
  end

  def kgs_format(number)
    number = number_format(number)
    number_with_delimiter(number_with_precision(number, precision: 2))
  end

  def cbm_format(number)
    number = number_format(number)
    number_with_delimiter(number_with_precision(number, precision: 3))
  end
end
