class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open without_admin managed valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.search(params, @current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def edit
    @admins = Administrator.includes(:user).all
    @valuators = Valuator.includes(:user).all.order("users.username ASC")
    @tags = ActsAsTaggableOn::Tag.spending_proposal_tags
  end

  def update
    if @spending_proposal.update(spending_proposal_params)
      redirect_to admin_spending_proposal_path(@spending_proposal, anchor: 'classification'), notice: t("flash.actions.update.spending_proposal")
    else
      render :edit
    end
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:administrator_id, :tag_list, valuator_ids: [])
    end

end
