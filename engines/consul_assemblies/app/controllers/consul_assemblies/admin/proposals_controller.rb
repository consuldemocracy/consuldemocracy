require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class Admin::ProposalsController < Admin::AdminController

    before_action :authenticate_user!
    before_action :load_meeting, only: [:index]


    def index
      @proposals = @meeting ? @meeting.proposals : ConsulAssemblies::Proposal
      @proposals = @proposals.order(position: 'asc').page(params[:page] || 1)
    end

    def new
      @proposal = ConsulAssemblies::Proposal.new(meeting_id: params[:meeting_id])
    end

    def edit
      @proposal = ConsulAssemblies::Proposal.find(params[:id])
    end

    def update
      @proposal = ConsulAssemblies::Proposal.find(params[:id])
      if @proposal.update(proposal_params)
        redirect_to admin_proposals_path(meeting_id: @proposal.meeting_id), notice: t('.proposal_updated')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def create
      @proposal = ConsulAssemblies::Proposal.new(proposal_params.merge({ is_previous_meeting_acceptance: false }))
      if @proposal.save
        redirect_to admin_proposals_path(meeting_id: @proposal.meeting_id), notice: t('.proposal_created')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def destroy
      @proposal = ConsulAssemblies::Proposal.find(params[:id])
      @proposal.destroy

      redirect_to admin_proposals_path(meeting_id: @proposal.meeting_id), notice: t('.proposal_destroyed')
    end

    def up
      @proposal = ConsulAssemblies::Proposal.find(params[:id])
      @proposal.move_higher
      redirect_to admin_proposals_path(meeting_id: @proposal.meeting_id)
    end

    def down
      @proposal = ConsulAssemblies::Proposal.find(params[:id])
      @proposal.move_lower
      redirect_to admin_proposals_path(meeting_id: @proposal.meeting_id)
    end

    private

    def load_meeting
      @meeting = ConsulAssemblies::Meeting.find(params[:meeting_id]) if params[:meeting_id]
    end

    def proposal_params
      params.require(:proposal).permit(
        :meeting_id,
        :title,
        :description,
        :user_id,
        :accepted,
        :terms_of_service,
        :created_at,
        :updated_at,
        :conclusion,
        :position,
        :proposal_origin,
        :acceptance_status,
        attachments_attributes: [:file, :title,:featured_image_flag, :_destroy, :id]
      )
    end

  end
end
