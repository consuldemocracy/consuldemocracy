class WelcomeController < ApplicationController
  skip_authorization_check

  def index
    @featured_debates = Debate.order("created_at DESC").limit(9)
    set_voted_values @featured_debates.map(&:id)
  end

end