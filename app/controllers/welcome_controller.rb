class WelcomeController < ApplicationController
  skip_authorization_check
  before_action :set_user_recommendations, only: :index, if: :current_user

  layout "devise", only: [:welcome, :verification]

  def index
  end

  def welcome
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  private

  def set_user_recommendations
    @recommended_debates = Debate.recommended(current_user).limit(3)
    @recommended_proposals = Proposal.recommended(current_user).limit(3)
  end

end
