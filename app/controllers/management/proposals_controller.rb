class Management::ProposalsController < Management::BaseController
  include HasOrders
  include CommentableActions

  before_action :only_verified_users, except: :print
  before_action :set_proposal, only: [:vote, :show]
  before_action :parse_search_terms, only: :index
  before_action :load_categories, only: [:new, :edit]
  before_action :load_geozones, only: [:edit]

  has_orders %w{confidence_score hot_score created_at most_commented random}, only: [:index, :print]
  has_orders %w{most_voted newest}, only: :show

  def show
    super
    @notifications = @proposal.notifications
    @related_contents = Kaminari.paginate_array(@proposal.relationed_contents).page(params[:page]).per(5)

    redirect_to management_proposal_path(@proposal), status: :moved_permanently if request.path != management_proposal_path(@proposal)
  end

  def vote
    @proposal.register_vote(managed_user, 'yes')
    set_proposal_votes(@proposal)
  end

  def print
    @proposals = Proposal.send("sort_by_#{@current_order}").for_render.limit(5)
    set_proposal_votes(@proposal)
  end

  private

    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    def proposal_params
      params.require(:proposal).permit(:title, :question, :summary, :description, :external_url, :video_url,
                                       :responsible_name, :tag_list, :terms_of_service, :geozone_id)
    end

    def resource_model
      Proposal
    end

    def only_verified_users
      check_verified_user t("management.proposals.alert.unverified_user")
    end

    def set_proposal_votes(proposals)
      @proposal_votes = managed_user ? managed_user.proposal_votes(proposals) : {}
    end

    def set_comment_flags(comments)
      @comment_flags = managed_user ? managed_user.comment_flags(comments) : {}
    end

end
