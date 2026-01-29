class Polls::PollHeaderComponent < ApplicationComponent
  attr_reader :poll
  delegate :auto_link_already_sanitized_html, to: :helpers

  def initialize(poll)
    @poll = poll
  end
end
