module LegislationHelper
  def format_date(date)
    l(date, format: "%d %b %Y")
  end
end
