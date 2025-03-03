class Polls::PollHeaderComponent < ApplicationComponent
  attr_reader :poll
  use_helpers :auto_link_already_sanitized_html

  def initialize(poll)
    @poll = poll
  end
end
