class Management::ProposalsController < Management::BaseController
  include HasOrders
  include CommentableActions
  include Translatable
  include MapLocationAttributes

  before_action :only_verified_users, except: :print
  before_action :set_proposal, only: [:vote, :show]
  before_action :parse_search_terms, only: :index
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
      load_geozones
      set_resource_instance
      render :new
    end
  end

  def show
    super
    @notifications = @proposal.notifications

    redirect_to management_proposal_path(@proposal), status: :moved_permanently if request.path != management_proposal_path(@proposal)
  end

  def vote
    @follow = Follow.find_or_create_by!(user: current_user, followable: @proposal)
    @proposal.register_vote(managed_user, "yes")
  end

  def print
    @proposals = Proposal.send("sort_by_#{@current_order}").for_render.limit(5)
  end

  private

    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    def proposal_params
      params.require(:proposal).permit(allowed_params)
    end

    def allowed_params
      attributes = [:video_url, :responsible_name, :tag_list,
                    :terms_of_service, :geozone_id,
                    map_location_attributes: map_location_attributes]

      [*attributes, translation_params(Proposal)]
    end

    def resource_model
      Proposal
    end

    def only_verified_users
      check_verified_user t("management.proposals.alert.unverified_user")
    end

    def set_comment_flags(comments)
      @comment_flags = managed_user ? managed_user.comment_flags(comments) : {}
    end
end
