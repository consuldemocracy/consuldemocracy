class SpendingProposalsController < ApplicationController
  include FeatureFlags

  load_and_authorize_resource

  before_action :authenticate_user!, except: [:index]
  before_action :verify_access, only: [:show]

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
      redirect_to @spending_proposal, notice: t("flash.actions.create.spending_proposal")
    else
      render :new
    end
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :terms_of_service, :captcha, :captcha_key)
    end

    def verify_access
      raise CanCan::AccessDenied unless current_user.try(:valuator?) || current_user.try(:administrator?) || @spending_proposal.author == current_user
    end

end
