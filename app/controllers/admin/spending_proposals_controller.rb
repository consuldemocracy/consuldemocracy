class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open without_admin managed valuating valuation_finished}, only: :index

  before_action :parse_search_terms, only: [:index]
  
  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.search(params, @current_filter).order(created_at: :desc).page(params[:page])
    @spending_proposals = @search_terms.present? ? @spending_proposals.search_title(@search_terms) : @spending_proposals.all
  end

  def show
    @admins = Administrator.includes(:user).all
    @valuators = Valuator.includes(:user).all.order("users.username ASC")
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

  def parse_search_terms 
    @search_terms = params[:search] if params[:search].present? 
  end 

end
