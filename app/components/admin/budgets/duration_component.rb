class Admin::Budgets::DurationComponent < ApplicationComponent
  attr_reader :durable

  def initialize(durable)
    @durable = durable
  end

  def dates
    safe_join([formatted_start_date, "-", formatted_end_date], " ")
  end

  def duration
    distance_of_time_in_words(durable.starts_at, durable.ends_at)
  end

  private

    def formatted_start_date
      formatted_date(durable.starts_at) if durable.starts_at.present?
    end

    def formatted_end_date
      formatted_date(durable.ends_at - 1.second) if durable.ends_at.present?
    end

    def formatted_date(time)
      time_tag(time, format: :datetime)
    end
end
