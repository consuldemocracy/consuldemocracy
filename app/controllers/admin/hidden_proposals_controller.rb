class Admin::HiddenProposalsController < Admin::BaseController
  include FeatureFlags
  include Admin::HiddenContent

  feature_flag :proposals

  before_action :load_proposal, only: [:confirm_hide, :restore]

  def index
    @proposals = hidden_content(Proposal.all)
  end

  def confirm_hide
    @proposal.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @proposal.restore(recursive: true)
    @proposal.ignore_flag
    Activity.log(current_user, :restore, @proposal)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_proposal
      @proposal = Proposal.with_hidden.find(params[:id])
    end
end
