class WelcomeController < ApplicationController
  skip_authorization_check

  def index
    @featured_debates = Debate.includes(:tags).limit(9)
    set_debate_votes(@featured_debates)
  end

end