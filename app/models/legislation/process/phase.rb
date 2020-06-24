class Legislation::Process::Phase
  def initialize(start_date, end_date, enabled)
    @start_date = start_date
    @end_date = end_date
    @enabled = enabled
  end

  def enabled?
    @enabled
  end

  def started?
    @start_date && enabled? && Date.current >= @start_date ? true : false
  end

  def open?
    started? && Date.current <= @end_date
  end
end
