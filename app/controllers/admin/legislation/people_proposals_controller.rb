class Admin::Legislation::PeopleProposalsController < Admin::Legislation::BaseController
  include ImageAttributes

  has_orders %w[id title supports], only: :index

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :people_proposal,
    class: "Legislation::PeopleProposal",
    through: :process

  def show

  end

  def update
    if @people_proposal.update(people_proposal_params)
      redirect_to admin_legislation_process_people_proposals_path(@process),
                  notice: I18n.t("flash.actions.update.people_proposal")
    else
      render :edit
    end
  end

  def create
    @people_proposal = @process.people_proposals.new(people_proposal_params
                                                        .merge(author: current_user)
                                                      )

    if @people_proposal.save
      redirect_to admin_legislation_process_people_proposals_path(@process),
                  notice: I18n.t("flash.actions.create.people_proposal")
    else
      render :new
    end
  end

  def index
    @people_proposals = @people_proposals.send("sort_by_#{@current_order}").page(params[:page])
  end

  def toggle_selection
    @people_proposal.toggle :selected
    @people_proposal.save!
  end

  def toggle_validation
    @people_proposal.toggle :validated
    @people_proposal.save!
  end

  private
    def people_proposal_params
      params.require(:legislation_people_proposal).permit(
        :title, :question, :summary, :description, :video_url, :responsible_name,
        :email, :phone, :website, :facebook, :twitter, :instagram, :youtube,
        :tag_list, :terms_of_service, :skip_map, image_attributes: image_attributes,
        documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy],
        map_location_attributes: [:latitude, :longitude, :zoom]
      )
    end
end
