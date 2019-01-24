class Admin::Legislation::ProposalsController < Admin::Legislation::BaseController

  has_orders %w[id title supports], only: :index

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

  def index
    @proposals = @proposals.send("sort_by_#{@current_order}").page(params[:page])
  end

  def toggle_selection
    @proposal.toggle :selected
    @proposal.save!
  end
end
