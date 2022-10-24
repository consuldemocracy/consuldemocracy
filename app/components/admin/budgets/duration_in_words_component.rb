class Admin::Budgets::DurationInWordsComponent < ApplicationComponent
  attr_reader :durable

  def initialize(durable)
    @durable = durable
  end

  def render?
    durable.starts_at && durable.ends_at
  end

  private

    def duration
      distance_of_time_in_words(durable.starts_at, durable.ends_at)
    end
end
