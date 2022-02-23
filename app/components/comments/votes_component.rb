class Comments::VotesComponent < ApplicationComponent
  attr_reader :comment
  delegate :current_user, :can?, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(comment)
    @comment = comment
  end
end
