class WelcomeController < ApplicationController
  before_action :track_campaign, only: :index
  skip_authorization_check

  layout "devise", only: [:welcome, :verification]

  def index
    if current_user
      redirect_to proposals_path
    end
    @proposal_successfull_exists = Proposal.successfull.exists?
  end

  def welcome
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  private

    def track_campaign
      session[:campaign_name] = I18n.t("tracking.events.name.home_joaquin_reyes")
    end
end
