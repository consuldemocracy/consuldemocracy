module ShiftsHelper

  def shift_vote_collection_dates(polls)
    date_options((start_date(polls)..end_date(polls)), Poll::Shift.tasks[:vote_collection])
  end

  def shift_recount_scrutiny_dates(polls)
    date_options(polls.map(&:ends_at).map(&:to_date).sort.inject([]) { |total, date| total << (date..date + 1.week).to_a }.flatten.uniq, Poll::Shift.tasks[:recount_scrutiny])
  end

  def date_options(dates, task_id)
    valid_dates(dates, task_id).map { |date| [l(date, format: :long), l(date)] }
  end

  def valid_dates(dates, task_id)
    dates.reject { |date| officer_shifts(task_id).include?(date) }
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

  private

  def officer_shifts(task_id)
    @officer.shifts.where(task: task_id).map(&:date)
  end
end
