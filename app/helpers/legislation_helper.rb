module LegislationHelper
  def format_date(date)
    l(date, format: "%d %b %Y") if date
  end
end
