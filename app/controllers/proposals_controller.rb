class ProposalsController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions

  before_action :parse_tag_filter, only: :index
  before_action :load_categories, only: [:index, :new, :create, :edit, :map, :summary]
  before_action :load_geozones, only: [:edit, :map, :summary]
  before_action :login_user!, only: :vote
  before_action :authenticate_user!, except: [:index, :show, :map, :summary]
  before_action :destroy_map_location_association, only: :update
  before_action :set_view, only: :index
  before_action :proposals_recommendations, only: :index, if: :current_user

  feature_flag :proposals

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Proposal.proposals_orders(c.current_user) }, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    @notifications = @proposal.notifications.not_moderated
    load_rank
    @document = Document.new(documentable: @proposal)
    @related_contents = Kaminari.paginate_array(@proposal.relationed_contents).page(params[:page]).per(5)

    redirect_to proposal_path(@proposal), status: :moved_permanently if request.path != proposal_path(@proposal)
  end

  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user))

    if @proposal.save
      log_event("proposal", "create")
      redirect_to share_proposal_path(@proposal), notice: I18n.t('flash.actions.create.proposal')
    else
      render :new
    end
  end

  def index_customization
    hide_proceedings
    discard_archived
    load_retired
    hide_advanced_search if custom_search?
    load_successful_proposals
    load_featured unless @proposal_successful_exists
  end

  def vote
    @proposal.register_vote(current_user, 'yes')

    if newsletter_vote?
      sign_out(:user)
      redirect_to @proposal, notice: t('proposals.notice.voted')
    else
      set_proposal_votes(@proposal)
    end

    load_rank
    log_event("proposal", 'support', @proposal.id, @proposal_rank, 6, @proposal_rank)
  end

  def retire
    if valid_retired_params? && @proposal.update(retired_params.merge(retired_at: Time.current))
      redirect_to proposal_path(@proposal), notice: t('proposals.notice.retired')
    else
      render action: :retire_form
    end
  end

  def retire_form
  end

  def share
    if Setting['proposal_improvement_path'].present?
      @proposal_improvement_path = Setting['proposal_improvement_path']
    end
  end

  def vote_featured
    @proposal.register_vote(current_user, 'yes')
    set_featured_proposal_votes(@proposal)
  end

  def summary
    @proposals = Proposal.for_summary
    @tag_cloud = tag_cloud
  end

  def new
    super
    @resource.proceeding = params[:proceeding]
    @resource.sub_proceeding = params[:sub_proceeding]
  end

  def disable_recommendations
    if current_user.update(recommended_proposals: false)
      redirect_to proposals_path, notice: t('proposals.index.recommendations.actions.success')
    else
      redirect_to proposals_path, error: t('proposals.index.recommendations.actions.error')
    end
  end

  private

    def proposal_params
      params.require(:proposal).permit(:title, :question, :summary, :description, :external_url, :video_url,
                                       :responsible_name, :tag_list, :terms_of_service, :geozone_id, :proceeding, :sub_proceeding, :skip_map,
                                       image_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy],
                                       documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy],
                                       map_location_attributes: [:latitude, :longitude, :zoom])
    end

    def retired_params
      params.require(:proposal).permit(:retired_reason, :retired_explanation)
    end

    def valid_retired_params?
      @proposal.errors.add(:retired_reason, I18n.t('errors.messages.blank')) if params[:proposal][:retired_reason].blank?
      @proposal.errors.add(:retired_explanation, I18n.t('errors.messages.blank')) if params[:proposal][:retired_explanation].blank?
      @proposal.errors.empty?
    end

    def resource_model
      Proposal
    end

    def set_featured_proposal_votes(proposals)
      @featured_proposals_votes = current_user ? current_user.proposal_votes(proposals) : {}
    end

    def discard_archived
      @resources = @resources.not_archived unless @current_order == "archival_date"
    end

    def load_retired
      if params[:retired].present?
        @resources = @resources.retired
        @resources = @resources.where(retired_reason: params[:retired]) if Proposal::RETIRE_OPTIONS.include?(params[:retired])
      else
      @resources = @resources.not_retired
      end
    end

    def load_featured
      return unless !@advanced_search_terms && @search_terms.blank? && @tag_filter.blank? && params[:retired].blank? && @current_order != "recommendations"
      @featured_proposals = Proposal.not_archived.not_proceedings.sort_by_confidence_score.limit(2)
      if @featured_proposals.present?
        set_featured_proposal_votes(@featured_proposals)
        @resources = @resources.where('proposals.id NOT IN (?)', @featured_proposals.map(&:id))
      end
    end

    def set_view
      @view = (params[:view] == "minimal") ? "minimal" : "default"
    end

    def hide_proceedings
      @resources = @resources.not_proceedings
    end

    def hide_advanced_search
      @advanced_search_terms = nil
    end

    def custom_search?
      params[:custom_search].present?
    end

    def load_successful_proposals
      @proposal_successful_exists = Proposal.successful.exists?
    end

    def destroy_map_location_association
      map_location = params[:proposal][:map_location_attributes]
      if map_location && (map_location[:longitude] && map_location[:latitude]).blank? && !map_location[:id].blank?
        MapLocation.destroy(map_location[:id])
      end
    end

    def load_rank
      @proposal_rank ||= Proposal.rank(@proposal)
    end

    def proposals_recommendations
      if Setting['feature.user.recommendations_on_proposals'] && current_user.recommended_proposals
        @recommended_proposals = Proposal.recommendations(current_user).sort_by_random.limit(3)
      end
    end

    def login_user!
      if newsletter_vote? && newsletter_user.present? && newsletter_user.level_two_or_three_verified?
        sign_in(:user, newsletter_user)
      end
    end

    def newsletter_vote?
      request.get? && params[:newsletter_token].present?
    end

    def newsletter_user
      User.where(newsletter_token: params[:newsletter_token]).first
    end

end
