class Admin::DurationComponent < ApplicationComponent
  attr_reader :durable

  def initialize(durable)
    @durable = durable
  end

  private

    def dates
      render Admin::DateRangeComponent.new(start_time, end_time)
    end

    def start_time
      durable.starts_at
    end

    def end_time
      if durable.ends_at.present? && durable.ends_at == durable.ends_at.beginning_of_day
        durable.ends_at - 1.second
      else
        durable.ends_at
      end
    end
end
