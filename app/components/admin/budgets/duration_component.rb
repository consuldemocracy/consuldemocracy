class Admin::Budgets::DurationComponent < ApplicationComponent
  attr_reader :durable

  def initialize(durable)
    @durable = durable
  end

  def dates
    Admin::DateRangeComponent.new(start_time, end_time).call
  end

  def duration
    distance_of_time_in_words(durable.starts_at, durable.ends_at) if durable.starts_at && durable.ends_at
  end

  private

    def start_time
      durable.starts_at
    end

    def end_time
      durable.ends_at - 1.second if durable.ends_at.present?
    end
end
