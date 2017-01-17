module LegislationHelper
  def format_date(date)
    l(date, format: "%d %b %Y") if date
  end

  def format_date_for_calendar_form(date)
    l(date, format: "%d/%m/%Y") if date
  end
end
