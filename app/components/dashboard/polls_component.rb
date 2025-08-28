class Dashboard::PollsComponent < ApplicationComponent
  attr_reader :polls

  def initialize(polls)
    @polls = polls
  end

  def render?
    polls.any?
  end
end
