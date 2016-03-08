class Valuation::SpendingProposalsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  before_action :restrict_access_to_assigned_items, only: [:show, :edit, :valuate]

  has_filters %w{valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    if current_user.valuator?
      @spending_proposals = SpendingProposal.search(params_for_current_valuator, @current_filter).order(created_at: :desc).page(params[:page])
    else
      @spending_proposals = SpendingProposal.none.page(params[:page])
    end
  end

  def valuate
    @spending_proposal.update_attributes(valuation_params)
    redirect_to valuation_spending_proposal_path(@spending_proposal), notice: t('valuation.spending_proposals.notice.valuate')
  end

  private

    def valuation_params
      params.require(:spending_proposal).permit(:price, :price_first_year, :price_explanation, :feasible, :feasible_explanation, :time_scope, :valuation_finished, :internal_comments)
    end

    def params_for_current_valuator
        params.merge({valuator_id: current_user.valuator.id})
    end

    def restrict_access_to_assigned_items
      raise ActionController::RoutingError.new('Not Found') unless current_user.administrator? || ValuationAssignment.exists?(spending_proposal_id: params[:id], valuator_id: current_user.valuator.id)
    end

end
