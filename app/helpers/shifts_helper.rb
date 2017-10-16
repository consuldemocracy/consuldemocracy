module ShiftsHelper

  def shift_vote_collection_dates(polls)
    date_options((start_date(polls)..end_date(polls)), 0)
  end

  def shift_recount_scrutiny_dates(polls)
    date_options(polls.map(&:ends_at).map(&:to_date).sort.inject([]) { |total, date| total << (date..date + 1.week).to_a }.flatten.uniq, 1)
  end

  def date_options(dates, task_id)
    dates.reject { |date| officer_shifts(task_id).include?(date) }.map { |date| [l(date, format: :long), l(date)] }
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
