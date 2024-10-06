class Admin::Legislation::ProposalsController < Admin::Legislation::BaseController
  has_orders %w[id title supports], only: :index

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

  def index
    @proposals = @proposals.send("sort_by_#{@current_order}").page(params[:page])
  end

  def select
    @proposal.update!(selected: true)

    render :toggle_selection
  end

  def deselect
    @proposal.update!(selected: false)

    render :toggle_selection
  end
end
