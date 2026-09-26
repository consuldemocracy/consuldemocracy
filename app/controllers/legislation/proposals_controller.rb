class Legislation::ProposalsController < Legislation::BaseController
  include CommentableActions
  include FlagActions
  include ImageAttributes

  before_action :load_categories, only: [:new, :create, :edit]
  before_action :authenticate_user!, except: :show
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w[most_voted newest oldest], only: :show

  respond_to :html, :js

  def show
    @remote_translation_resources = @proposal
    @document = Document.new(documentable: @proposal)
    if request.path != legislation_process_proposal_path(params[:process_id], @proposal)
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  status: :moved_permanently
    end
  end

  def new
    @proposal = Legislation::Proposal.new
  end

  def create
    @proposal = Legislation::Proposal.new(proposal_params.merge(author: current_user))

    if @proposal.save
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  def suggest
    @proposals = Legislation::Proposal.all
  end

  def update
    if @proposal.update(proposal_params)
      redirect_to polymorphic_path(@proposal), notice: t("flash.actions.update.proposal")
    else
      render :edit
    end
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
end
