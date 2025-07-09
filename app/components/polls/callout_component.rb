class Polls::CalloutComponent < ApplicationComponent
  attr_reader :poll
  use_helpers :can?, :current_user, :link_to_signin, :link_to_signup

  def initialize(poll)
    @poll = poll
  end
end
