class Legislation::Process::Publication
  def initialize(publication_date, enabled)
    @publication_date = publication_date
    @enabled = enabled
  end

  def enabled?
    @enabled
  end

  def started?
    @publication_date.nil? || enabled? && Date.current >= @publication_date
  end

  def open?
    started?
  end
end
