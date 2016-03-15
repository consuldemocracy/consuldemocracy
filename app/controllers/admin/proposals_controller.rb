class Admin::ProposalsController < Admin::BaseController
  has_filters %w{without_confirmed_hide all with_confirmed_hide}, only: :index

  before_action :load_proposal, only: [:confirm_hide, :restore]
  before_action :parse_search_terms, only: [:index]

  def index
    @proposals = Proposal.only_hidden.send(@current_filter).order(hidden_at: :desc).page(params[:page])
    @proposals = @proposals.search(@search_terms)  if @search_terms.present? 
  end

  def confirm_hide
    @proposal.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @proposal.restore
    @proposal.ignore_flag
    Activity.log(current_user, :restore, @proposal)
    redirect_to request.query_parameters.merge(action: :index)
  end

  def parse_search_terms 
    @search_terms = params[:search] if params[:search].present? 
  end 

  private

    def load_proposal
      @proposal = Proposal.with_hidden.find(params[:id])
    end

end
