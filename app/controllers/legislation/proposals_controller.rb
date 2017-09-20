class Legislation::ProposalsController < Legislation::BaseController
  include CommentableActions
  include FlagActions

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

  before_action :parse_tag_filter, only: :index
  before_action :load_categories, only: [:index, :new, :create, :edit, :map, :summary]
  before_action :load_geozones, only: [:edit, :map, :summary]
  before_action :authenticate_user!, except: [:index, :show, :map, :summary]

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w{hot_score confidence_score created_at relevance archival_date}, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    set_legislation_proposal_votes(@process.proposals)
    @notifications = @proposal.notifications
    @document = Document.new(documentable: @proposal)
    redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                status: :moved_permanently if request.path != legislation_process_proposal_path(params[:process_id], @proposal)
  end

  def create
    @proposal = Legislation::Proposal.new(proposal_params.merge(author: current_user))
    recover_documents_from_cache(@proposal)

    if @proposal.save
      redirect_to share_legislation_process_proposal_path(params[:process_id], @proposal), notice: I18n.t('flash.actions.create.proposal')
    else
      render :new
    end
  end

  def index_customization
    discard_archived
    load_retired
    load_successful_proposals
    load_featured unless @proposal_successful_exists
  end

  def vote
    @proposal.register_vote(current_user, 'yes')
    set_legislation_proposal_votes(@proposal)
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
    @proposals = Legislation::Proposal.for_summary
    @tag_cloud = tag_cloud
  end

  private

    def proposal_params
      params.require(:legislation_proposal).permit(:legislation_process_id, :title, :question, :summary, :description, :external_url, :video_url,
                                       :responsible_name, :tag_list, :terms_of_service, :geozone_id,
                                       documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id] )
    end

    def retired_params
      params.require(:legislation_proposal).permit(:retired_reason, :retired_explanation)
    end

    def valid_retired_params?
      @proposal.errors.add(:retired_reason, I18n.t('errors.messages.blank')) if params[:legislation_proposal][:retired_reason].blank?
      @proposal.errors.add(:retired_explanation, I18n.t('errors.messages.blank')) if params[:legislation_proposal][:retired_explanation].blank?
      @proposal.errors.empty?
    end

    def resource_model
      Legislation::Proposal
    end

    def resource_name
      'proposal'
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
        @resources = @resources.where(retired_reason: params[:retired]) if Legislation::Proposal::RETIRE_OPTIONS.include?(params[:retired])
      else
        @resources = @resources.not_retired
      end
    end

    def load_featured
      return unless !@advanced_search_terms && @search_terms.blank? && @tag_filter.blank? && params[:retired].blank?
      @featured_proposals = Legislation::Proposal.not_archived.sort_by_confidence_score.limit(3)
      if @featured_proposals.present?
        set_featured_proposal_votes(@featured_proposals)
        @resources = @resources.where('proposals.id NOT IN (?)', @featured_proposals.map(&:id))
      end
    end

    def load_successful_proposals
      @proposal_successful_exists = Legislation::Proposal.successful.exists?
    end

end
