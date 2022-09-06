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
      durable.ends_at - 1.second if durable.ends_at.present?
    end
end
