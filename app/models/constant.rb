class Constant
  MIN_YEAR = 2018
  MAX_YEAR = 2022

  SORTED_BY = [["Yearly", "yearly"], ["Monthly", "monthly"], ["Date", "date"], ["All", "all"]]
  FILTER_BY = [["Yearly", "yearly"], ["Monthly", "monthly"], ["Date", "date"], ["All", "all"]]
  FORMAT = [["PDF", "pdf"], ["XLS", "xls"]]

  def self.years_range
    # Constant::MAX_YEAR.downto(Constant::MIN_YEAR)
    self.max_year.downto(Constant::MIN_YEAR)
  end

  def self.max_year
  	Date.today.month == 12 ? (Date.today.year + 1) : Date.today.year
  end
end
