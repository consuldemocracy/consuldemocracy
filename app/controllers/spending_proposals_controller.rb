class SpendingProposalsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  load_and_authorize_resource

  def index
  end

  def new
    @spending_proposal = SpendingProposal.new
    @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = current_user

    if @spending_proposal.save_with_captcha
      redirect_to spending_proposals_path, notice: t('flash.actions.create.notice', resource_name: t("activerecord.models.spending_proposal", count: 1))
    else
      @featured_tags = ActsAsTaggableOn::Tag.where(featured: true)
      render :new
    end
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :terms_of_service, :captcha, :captcha_key)
    end

end