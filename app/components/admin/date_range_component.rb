class Admin::DateRangeComponent < ApplicationComponent
  attr_reader :start_time, :end_time

  def initialize(start_time, end_time)
    @start_time = start_time
    @end_time = end_time
  end

  def call
    safe_join([formatted_start_time, "-", formatted_end_time], " ")
  end

  private

    def formatted_start_time
      formatted_date(start_time) if start_time.present?
    end

    def formatted_end_time
      formatted_date(end_time) if end_time.present?
    end

    def formatted_date(time)
      time_tag(time, format: :short_datetime)
    end
end
