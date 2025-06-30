class Dashboard::PollComponent < ApplicationComponent
  attr_reader :poll

  def initialize(poll)
    @poll = poll
  end

  private

    def proposal
      poll.related
    end
end
