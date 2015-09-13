class Moderation::ProposalsController < Moderation::BaseController
  load_and_authorize_resource
  def hide
    @proposal.hide
  end
end
