class Dashboard::PollComponent < ApplicationComponent
  with_collection_parameter :poll

  attr_reader :poll, :proposal

  def initialize(poll:, proposal:)
    @poll = poll
    @proposal = proposal
  end
end
