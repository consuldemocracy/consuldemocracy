# frozen_string_literal: true

class Legislation::Process::Publication

  def initialize(publication_date)
    @publication_date = publication_date
  end

  def enabled?
    @publication_date.present?
  end

  def started?
    enabled? && Date.current >= @publication_date
  end

  def open?
    started?
  end

end
