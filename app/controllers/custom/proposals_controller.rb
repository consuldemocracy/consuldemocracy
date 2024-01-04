class ProposalsController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions
  include ImageAttributes
  include DocumentAttributes
  include MapLocationAttributes
  include Translatable

  before_action :load_categories, only: [:index, :map, :summary]
  before_action :load_geozones, only: [:edit, :map, :summary]
  before_action :authenticate_user!, except: [:index, :show, :map, :summary]
  before_action :set_view, only: :index
  before_action :proposals_recommendations, only: :index, if: :current_user

  feature_flag :proposals

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Proposal.proposals_orders(c.current_user) }, only: :index
  has_orders %w[most_voted newest oldest], only: :show

  load_and_authorize_resource
  before_action :destroy_map_location_association, only: :update

  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    @notifications = @proposal.notifications
    @notifications = @proposal.notifications.not_moderated

    if request.path != proposal_path(@proposal)
      redirect_to proposal_path(@proposal), status: :moved_permanently
    end
  end

  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user))
    if @proposal.save
      redirect_to created_proposal_path(@proposal), notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  def created; end

  def index_customization
    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links
  end

  def vote
    @follow = Follow.find_or_create_by!(user: current_user, followable: @proposal)
    @proposal.register_vote(current_user, "yes")
  end

  def un_vote
    @follow = Follow.find_or_create_by!(user: current_user, followable: @proposal)
    @follow&.destroy
    @proposal.register_vote(current_user, "no")
  end

  def retire
    if @proposal.update(retired_params.merge(retired_at: Time.current))
      redirect_to proposal_path(@proposal), notice: t("proposals.notice.retired")
    else
      render action: :retire_form
    end
  end

  def retire_form
  end

  def summary
    @proposals = Proposal.for_summary
    @tag_cloud = tag_cloud
  end

  def map
    @proposal = Proposal.new
    @tag_cloud = tag_cloud
  end

  def disable_recommendations
    if current_user.update(recommended_proposals: false)
      redirect_to proposals_path, notice: t("proposals.index.recommendations.actions.success")
    else
      redirect_to proposals_path, error: t("proposals.index.recommendations.actions.error")
    end
  end

  def publish
    @proposal.publish
    redirect_to share_proposal_path(@proposal), notice: t("proposals.notice.published")
  end

  private

  def proposal_params
    params.require(:proposal).permit(allowed_params)
  end

  def allowed_params
    attributes = [:video_url, :responsible_name, :tag_list, :terms_of_service,
                  :geozone_id, :related_sdg_list,
                  image_attributes: image_attributes,
                  documents_attributes: document_attributes,
                  map_location_attributes: map_location_attributes]
    translations_attributes = translation_params(Proposal, except: :retired_explanation)

    [*attributes, translations_attributes]
  end

  def retired_params
    params.require(:proposal).permit(allowed_retired_params)
  end

  def allowed_retired_params
    [:retired_reason, translation_params(Proposal, only: :retired_explanation)]
  end

  def resource_model
    Proposal
  end

  def discard_draft
    @resources = @resources.published
  end

  def discard_archived
    unless @current_order == "archival_date" || params[:selected].present?
      @resources = @resources.not_archived
    end
  end

  def load_retired
    if params[:retired].present?
      @resources = @resources.retired

      if Proposal::RETIRE_OPTIONS.include?(params[:retired])
        @resources = @resources.where(retired_reason: params[:retired])
      end
    else
      @resources = @resources.not_retired
    end
  end

  def load_selected
    if params[:selected].present?
      @resources = @resources.selected
    else
      @resources = @resources.not_selected
    end
  end

  def load_featured
    return if @advanced_search_terms || @search_terms.present? ||
      params[:retired].present? || @current_order == "recommendations"

    if Setting["feature.featured_proposals"]
      @featured_proposals = Proposal.not_archived
                                    .unsuccessful
                                    .sort_by_confidence_score
                                    .limit(Setting["featured_proposals_number"])
      if @featured_proposals.present?
        @resources = @resources.where.not(id: @featured_proposals)
      end
    end
  end

  def remove_archived_from_order_links
    @valid_orders.delete("archival_date")
  end

  def set_view
    @view = (params[:view] == "minimal") ? "minimal" : "default"
  end

  def destroy_map_location_association
    map_location_params = proposal_params[:map_location_attributes]

    if map_location_params.blank? || map_location_params.values.all?(&:blank?)
      @proposal.map_location = nil
    end
  end

  def proposals_recommendations
    if Setting["feature.user.recommendations_on_proposals"] && current_user.recommended_proposals
      @recommended_proposals = Proposal.recommendations(current_user).sort_by_random.limit(3)
    end
  end
end
