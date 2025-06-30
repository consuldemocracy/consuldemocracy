class Dashboard::PollComponent < ApplicationComponent
  attr_reader :poll, :proposal

  def initialize(poll, proposal)
    @poll = poll
    @proposal = proposal
  end
end
