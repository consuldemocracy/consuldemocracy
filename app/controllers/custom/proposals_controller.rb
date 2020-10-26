require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController
  include ProposalsHelper

  before_action(except: [:json_data, :index, :show, :map, :summary]) {authenticate_user!}
  before_action :redirect, only: :index

  load_and_authorize_resource except: :json_data

  skip_authorization_check only: :json_data

  def redirect
    if (params[:search].present?) && (!current_user.present? || !(current_user.moderator? || current_user.administrator?)) then
        params[:project] = params[:search]
    end
    
    if (!params[:project].present? || !Tag.category_names.include?(params[:project])) &&
      (!current_user.present? || !(current_user.moderator? || current_user.administrator?)) then
        redirect_to "/"
    end
  end

  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user))
    if @proposal.save
      proposal_created_email(@proposal)
      redirect_to created_proposal_path(@proposal), notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  def index_customization
    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links
    take_only_by_tag_name
    @proposals_coordinates = all_proposal_map_locations
  end

  def json_data
    proposal = Proposal.find(params[:id])
    data = {
      proposal_id: proposal.id,
      proposal_title: proposal.title
    }.to_json

    respond_to do |format|
      format.json { render json: data }
    end
  end

  private
    def take_only_by_tag_name
      if params[:project].present?
        @resources = @resources.proposals_by_category(params[:project])
      end
    end
    
    def all_active_proposals
     	if params[:project]
    		Proposal.published().not_retired().not_archived().proposals_by_category(params[:project])
    	elsif params[:search]
      		Proposal.published().not_retired().not_archived().search(params[:search])
	else
	  Proposal.published().not_retired().not_archived().all
	end
    end
  
    def proposal_created_email(proposal)
      @proposal = proposal
      @project = @proposal.tag_list_with_limit(1)
      if !@project.empty?
        @officials_by_project = User.officials_by_project(@project.first)
        @officials_by_project.each do |official|
          Mailer.proposal_created(@proposal, official).deliver_later
        end
      end
    end
end
