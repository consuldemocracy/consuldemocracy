class Moderation::ProposalsController < Moderation::BaseController

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{created_at flags}, only: :index

  before_filter :load_proposals, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(@current_filter)
                           .send("sort_by_#{@current_order}")
                           .page(params[:page])
                           .per(50)
  end

  def hide
    @proposal.hide
  end

  def moderate
    @proposals = @proposals.where(id: params[:proposal_ids])

    if params[:hide_proposals].present?
      @proposals.accessible_by(current_ability, :hide).each(&:hide)

    elsif params[:ignore_flags].present?
      @proposals.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)

    elsif params[:block_authors].present?
      author_ids = @proposals.pluck(:author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each(&:block)
    end

    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_proposals
      @proposals = Proposal.accessible_by(current_ability, :moderate)
    end

end
