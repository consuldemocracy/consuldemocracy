module ShiftsHelper

  def shift_dates_select_options(polls)
    options = []
    (start_date(polls)..end_date(polls)).each do |date|
      options << [l(date, format: :long), l(date)]
    end
    options_for_select(options, params[:date])
  end

  def start_date(polls)
    polls.map(&:starts_at).min.to_date
  end

  def end_date(polls)
    polls.map(&:ends_at).max.to_date
  end

  def officer_select_options(officers)
    officers.collect { |officer| [officer.name, officer.id] }
  end

end
