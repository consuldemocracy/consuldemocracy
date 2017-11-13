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

  has_orders %w{confidence_score created_at}, only: :index
  has_orders %w{most_voted newest oldest}, only: :show

  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    legislation_proposal_votes(@process.proposals)
    @document = Document.new(documentable: @proposal)
    if request.path != legislation_process_proposal_path(params[:process_id], @proposal)
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  status: :moved_permanently
    end
  end

  def create
    @proposal = Legislation::Proposal.new(proposal_params.merge(author: current_user))

    if @proposal.save
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal), notice: I18n.t('flash.actions.create.proposal')
    else
      render :new
    end
  end

  def index_customization
    load_successful_proposals
    load_featured unless @proposal_successful_exists
  end

  def vote
    @proposal.register_vote(current_user, params[:value])
    legislation_proposal_votes(@proposal)
  end

  private

    def proposal_params
      params.require(:legislation_proposal).permit(:legislation_process_id, :title,
                    :question, :summary, :description, :video_url, :tag_list,
                    :terms_of_service, :geozone_id,
                    documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id])
    end

    def resource_model
      Legislation::Proposal
    end

    def resource_name
      'proposal'
    end

    def load_successful_proposals
      @proposal_successful_exists = Legislation::Proposal.successful.exists?
    end

end
