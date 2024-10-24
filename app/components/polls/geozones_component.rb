class Polls::GeozonesComponent < ApplicationComponent
  attr_reader :poll

  def initialize(poll)
    @poll = poll
  end

  def render?
    poll.geozones.any?
  end
end
