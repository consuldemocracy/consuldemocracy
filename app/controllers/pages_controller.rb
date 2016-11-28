class PagesController < ApplicationController
  before_action :track_campaign
  skip_authorization_check

  def show
    @proposal_successfull_exists = Proposal.successfull.exists?
    render action: params[:id]
  rescue ActionView::MissingTemplate
    head 404
  end

  private

    def track_campaign
      if request.path == blas_bonilla_path
        session[:campaign_name] = I18n.t("tracking.events.name.joaquin_reyes")
      end
    end
end
