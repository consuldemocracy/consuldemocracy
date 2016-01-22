class SpendingProposalsController < ApplicationController
  include FeatureFlags

  before_action :authenticate_user!, except: [:index]

  load_and_authorize_resource

  feature_flag :spending_proposals

  def index
  end

  def new
    @spending_proposal = SpendingProposal.new
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = current_user

    if @spending_proposal.save_with_captcha
      redirect_to spending_proposals_path, notice: t("flash.actions.create.spending_proposal")
    else
      render :new
    end
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :terms_of_service, :captcha, :captcha_key)
    end

end
