class ProposalsController < ApplicationController
  include CommentableActions
  include FlagActions

  before_action :set_search_order, only: [:index]
  before_action :authenticate_user!, except: [:index, :show]

  has_orders %w{hot_score confidence_score created_at most_commented random relevance}, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource
  respond_to :html, :js

  def index
    @filter = ProposalFilter.new(params)
    @proposals = @filter.collection

    @proposals = @proposals.page(params[:page]).for_render.send("sort_by_#{@current_order}")

    set_resource_votes(@proposals)

    @featured_proposals = Proposal.all.sort_by_confidence_score.limit(3) if (@filter.search_filter.blank? && @filter.tag_filter.blank?)
    if @featured_proposals.present?
      set_featured_proposal_votes(@featured_proposals)
      @proposals = @proposals.where('proposals.id NOT IN (?)', @featured_proposals.map(&:id))
    end
  end

  def vote
    @proposal.register_vote(current_user, 'yes')
    set_proposal_votes(@proposal)
  end

  def vote_featured
    @proposal.register_vote(current_user, 'yes')
    set_featured_proposal_votes(@proposal)
  end

  private

    def proposal_params
      params.require(:proposal).permit(:title, :question, :summary, :description, :external_url, :video_url, :responsible_name, :tag_list, :terms_of_service, :captcha, :captcha_key, :category_id, :subcategory_id, :scope, :district)
    end

    def resource_model
      Proposal
    end

    def set_featured_proposal_votes(proposals)
      @featured_proposals_votes = current_user ? current_user.proposal_votes(proposals) : {}
    end
end
