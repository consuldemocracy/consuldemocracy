class WelcomeController < ApplicationController
  skip_authorization_check

  def index
    @featured_debates = Debate.sort_by_hot_score.limit(3).for_render
    set_debate_votes(@featured_debates)
  end

end
