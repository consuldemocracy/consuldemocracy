class Legislation::ProposalsController < Legislation::BaseController
  include CommentableActions
  include FlagActions
  include ImageAttributes

  before_action :load_categories, only: [:new, :create, :edit, :map, :summary]
  before_action :load_geozones, only: [:edit, :map, :summary]

  before_action :authenticate_user!, except: [:show, :map, :summary]
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w[most_voted newest oldest], only: :show

  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    @document = Document.new(documentable: @proposal)
    if request.path != legislation_process_proposal_path(params[:process_id], @proposal)
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  status: :moved_permanently
    end
  end

  def create
    @proposal = Legislation::Proposal.new(proposal_params.merge(author: current_user))

    if @proposal.save
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal), notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  def vote
    @proposal.register_vote(current_user, params[:value])
  end

  private

    def proposal_params
      params.require(:legislation_proposal).permit(allowed_params)
    end

    def allowed_params
      [
        :legislation_process_id, :title,
        :summary, :description, :video_url, :tag_list,
        :terms_of_service, :geozone_id,
        image_attributes: image_attributes,
        documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id]
      ]
    end

    def resource_model
      Legislation::Proposal
    end

    def resource_name
      "proposal"
    end
end
