# frozen_string_literal: true

class Legislation::Process::Phase

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def enabled?
    @start_date.present? && @end_date.present?
  end

  def started?
    enabled? && Date.current >= @start_date
  end

  def open?
    started? && Date.current <= @end_date
  end

end
