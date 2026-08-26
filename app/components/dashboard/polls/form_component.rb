class Dashboard::Polls::FormComponent < ApplicationComponent
  attr_reader :poll
  delegate :admin_submit_action, to: :helpers

  def initialize(poll)
    @poll = poll
  end

  private

    def proposal
      poll.related
    end
end
