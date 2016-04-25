class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open without_admin managed valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.scoped_filter(params, @current_filter).order(cached_votes_up: :desc, created_at: :desc).page(params[:page])
  end

  def show
  end

  def edit
    @admins = Administrator.includes(:user).all
    @valuators = Valuator.includes(:user).all.order("description ASC").order("users.email ASC")
    @tags = ActsAsTaggableOn::Tag.spending_proposal_tags
  end

  def update
    if @spending_proposal.update(spending_proposal_params)
      redirect_to admin_spending_proposal_path(@spending_proposal, SpendingProposal.filter_params(params)),
                  notice: t("flash.actions.update.spending_proposal")
    else
      render :edit
    end
  end

  def summary
    @spending_proposals = SpendingProposal.for_summary.group(:geozone).sum(:price)
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :administrator_id, :tag_list, valuator_ids: [])
    end

end
