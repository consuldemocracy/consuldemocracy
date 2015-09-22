class Moderation::ProposalsController < Moderation::BaseController

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  before_filter :load_proposals, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @proposals = @proposals.send(@current_filter)
                           .send("sort_by_#{@current_order}")
                           .page(params[:page])
                           .per(50)
  end

  def hide
    hide_proposal @proposal
  end

  def moderate
    @proposals = @proposals.where(id: params[:proposal_ids])

    if params[:hide_proposals].present?
      @proposals.accessible_by(current_ability, :hide).each {|proposal| hide_proposal proposal}

    elsif params[:ignore_flags].present?
      @proposals.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)

    elsif params[:block_authors].present?
      author_ids = @proposals.pluck(:author_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each {|user| block_user user}
    end

    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_proposals
      @proposals = Proposal.accessible_by(current_ability, :moderate)
    end

    def hide_proposal(proposal)
      proposal.hide
      Activity.log(current_user, :hide, proposal)
    end

    def block_user(user)
      user.block
      Activity.log(current_user, :block, user)
    end

end
