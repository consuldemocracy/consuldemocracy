class Admin::HiddenProposalsController < Admin::BaseController
  include FeatureFlags

  has_filters %w[without_confirmed_hide all with_confirmed_hide], only: :index

  feature_flag :proposals

  before_action :load_proposal, only: [:confirm_hide, :restore]

  def index
    @proposals = Proposal.only_hidden.send(@current_filter).order(hidden_at: :desc)
                         .page(params[:page])
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

  private

    def load_proposal
      @proposal = Proposal.with_hidden.find(params[:id])
    end

end
