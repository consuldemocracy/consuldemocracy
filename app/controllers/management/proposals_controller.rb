class Management::ProposalsController < Management::BaseController
  include HasOrders
  include CommentableActions
  include Translatable

  before_action :only_verified_users, except: :print
  before_action :set_proposal, only: [:vote, :show]
  before_action :parse_search_terms, only: :index
  before_action :load_categories, only: [:new, :edit]
  before_action :load_geozones, only: [:edit]

  has_orders %w[confidence_score hot_score created_at most_commented random], only: [:index, :print]
  has_orders %w[most_voted newest], only: :show

  def create
    @resource = resource_model.new(strong_params.merge(author: current_user,
                                                       published_at: Time.current))

    if @resource.save
      track_event
      redirect_path = url_for(controller: controller_name, action: :show, id: @resource.id)
      redirect_to redirect_path, notice: t("flash.actions.create.#{resource_name.underscore}")
    else
      load_categories
      load_geozones
      set_resource_instance
      render :new
    end
  end

  def show
    super
    @notifications = @proposal.notifications
    related_contents_without_retired_proposals = @proposal.relationed_contents.select { |rel| rel[:retired_at] == nil }
    @related_contents = Kaminari.paginate_array(related_contents_without_retired_proposals)
                                .page(params[:page]).per(5)

    redirect_to management_proposal_path(@proposal), status: :moved_permanently if request.path != management_proposal_path(@proposal)
  end

  def vote
    @follow = Follow.find_or_create_by!(user: current_user, followable: @proposal)
    @proposal.register_vote(managed_user, "yes")
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
      attributes = [:video_url, :responsible_name, :tag_list,
                    :terms_of_service, :geozone_id,
                    :skip_map, map_location_attributes: [:latitude, :longitude, :zoom]]
      params.require(:proposal).permit(attributes, translation_params(Proposal))
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
