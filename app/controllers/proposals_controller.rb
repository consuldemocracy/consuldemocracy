class ProposalsController < ApplicationController
  include CommentableActions
  include FlagActions

  before_action :parse_tag_filter, only: :index
  before_action :load_categories, only: [:index, :new, :edit, :map, :summary]
  before_action :load_geozones, only: [:edit, :map, :summary]
  before_action :authenticate_user!, except: [:index, :show, :map, :summary]

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w{data_challenges hot_score confidence_score created_at relevance archival_date}, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    @notifications = @proposal.notifications
    redirect_to proposal_path(@proposal), status: :moved_permanently if request.path != proposal_path(@proposal)
  end

  def new
    @proposal.build_problem
  end

  # def create
  #   if !proposal_params[:problem_id].blank?
  #     p "PARAMETROS DE PROPUESTAS ANTES DE CREAR"
  #     p proposal_params
  #     params[:proposal].delete :problem_attributes
  #     p proposal_params
  #     p "user id"
  #     p params[:user_id]
  #     p proposal_params[:user_id]
  #     userid = params[:proposal][:user_id]
  #     params[:proposal][:author_id] = userid
  #     params[:proposal].merge(:author_id => params[:user_id])
  #     p "PARAMETROS DE PROPUESTAS DESPUES DEL IF"
  #     p proposal_params
  #   end
  #   @proposal = Proposal.new(proposal_params)
  #   p "PARAMETROS DE PROPUESTAS DESPUES DEL NEW"
  #   p proposal_params
  #   if @proposal.save
  #     redirect_to proposal_path(@proposal)
  #   else
  #     p @proposal.errors
  #     render :new
  #   end
  # end

  def index_customization
    discard_archived
    load_retired
    load_successful_proposals
    load_featured unless @proposal_successful_exists
  end

  def vote
    @proposal.register_vote(current_user, 'yes')
    set_proposal_votes(@proposal)
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

  def vote_featured
    @proposal.register_vote(current_user, 'yes')
    set_featured_proposal_votes(@proposal)
  end

  def summary
    @proposals = Proposal.for_summary
    @tag_cloud = tag_cloud
  end

  private

    def proposal_params
      params.require(:proposal).permit(:title, :responsible_name, :author_id, :question, :summary, :description, :external_url, :video_url, :for_challenge, :responsible_name, :tag_list, :prioritize, :what, :why, :terms_of_service,  :problem_id, geozone_ids: [],  problem_attributes: [:id, :title, :summary, :description, :cause, :consequence, :user_id])
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
      @featured_proposals = Proposal.not_archived.sort_by_confidence_score.limit(3) if (!@advanced_search_terms && @search_terms.blank? && @tag_filter.blank? && params[:retired].blank?)
      if @featured_proposals.present?
        set_featured_proposal_votes(@featured_proposals)
        @resources = @resources.where('proposals.id NOT IN (?)', @featured_proposals.map(&:id))
      end
    end

    def load_successful_proposals
      @proposal_successful_exists = Proposal.successful.exists?
    end

    # TODO:
    def load_municipality_proposals
      @proposal_municipality = Proposal.where(problem.user.administrator != nil)
    end

end
