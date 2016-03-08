class Valuation::SpendingProposalsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.search(params, @current_filter).order(created_at: :desc).page(params[:page])
  end

  def valuate
    @spending_proposal.update_attributes(valuation_params)
    redirect_to valuation_spending_proposal_path(@spending_proposal), notice: t('valuation.spending_proposals.notice.valuate')
  end

  private

    def valuation_params
      params.require(:spending_proposal).permit(:price, :price_first_year, :price_explanation, :feasible, :feasible_explanation, :time_scope, :valuation_finished, :internal_comments)
    end

end
