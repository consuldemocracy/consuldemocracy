class Legislation::PeopleProposalsController < Legislation::BaseController
  include CommentableActions
  include FlagActions
  include ImageAttributes

  before_action :parse_tag_filter, only: :index
  before_action :load_categories, only: [:index, :new, :create, :edit, :map, :summary]
  before_action :load_geozones, only: [:edit, :map, :summary]

  before_action :authenticate_user!, except: [:index, :show, :map, :summary]
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :people_proposal, class: "Legislation::PeopleProposal",
                              through: :process

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w[most_voted newest oldest], only: :show

  helper_method :resource_model, :resource_name
  respond_to :html, :js

  def show
    super
    legislation_people_proposal_votes(@process.people_proposals)
    @document = Document.new(documentable: @people_proposal)
    if request.path != legislation_process_people_proposal_path(params[:process_id],
                                                                @people_proposal)
      redirect_to legislation_process_people_proposal_path(params[:process_id], @people_proposal),
                  status: :moved_permanently
    end
  end

  def create
    complete_people_proposal_params = people_proposal_params.merge(author: current_user)
    @people_proposal = Legislation::PeopleProposal.new(complete_people_proposal_params)

    if @people_proposal.save
      redirect_to legislation_process_people_proposals_path(params[:process_id]),
                  notice: I18n.t("flash.actions.create.people_proposal")
    else
      render :new
    end
  end

  def vote
    @people_proposal.register_vote(current_user, params[:value])
    legislation_people_proposal_votes(@people_proposal)
  end

  private

    def people_proposal_params
      params.require(:legislation_people_proposal).permit(:legislation_process_id, :title,
                    :summary, :description, :video_url, :tag_list, :terms_of_service,
                    image_attributes: image_attributes,
                    documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id])
    end

    def resource_model
      Legislation::PeopleProposal
    end

    def resource_name
      "people_proposal"
    end
end
