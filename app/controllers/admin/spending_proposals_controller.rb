class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open without_admin managed valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.search(params, @current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    @admins = Administrator.includes(:user).all
    @valuators = Valuator.includes(:user).all.order("users.username ASC")
  end

  def edit
    @spending_proposal = SpendingProposal.find(params[:id])
    @admins = Administrator.includes(:user).all
    @tags = ActsAsTaggableOn::Tag.where('taggings.taggable_type' => 'SpendingProposal').includes(:taggings)
  end

  def update
    @spending_proposal = SpendingProposal.find(params[:id])
    if @spending_proposal.update(spending_proposal_params)
      redirect_to admin_spending_proposal_path(@spending_proposal), notice: t("flash.actions.update.spending_proposal")
    else
      render :edit
    end
  end

  def assign_admin
    @spending_proposal.update(params.require(:spending_proposal).permit(:administrator_id))
    render nothing: true
  end

  def assign_valuators
    params[:spending_proposal] ||= {}
    params[:spending_proposal][:valuator_ids] ||= []
    @spending_proposal.update(params.require(:spending_proposal).permit(valuator_ids: []))
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:administrator_id, :tag_list)
    end

end
