class Comments::VotesComponent < ApplicationComponent
  attr_reader :comment
  delegate :user_signed_in?, :can?, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(comment)
    @comment = comment
  end
end
