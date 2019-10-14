require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class Admin::MeetingsController < Admin::AdminController


    before_action :authenticate_user!
    before_action :load_meeting,  only: [:act, :draft]
    before_action :load_assembly, only: [:index, :new]
    before_action :load_assemblies, only: [:create, :new, :edit, :update]



    def act; end
    def draft; end

    def new

      new_parameters = {assembly_id: params[:assembly_id], user: current_user}
      about_venue = @assembly.try(:about_venue)
      new_parameters = new_parameters.merge({about_venue: about_venue}) if about_venue.present?
      @meeting = ConsulAssemblies::Meeting.new(new_parameters)
    end

    def edit
      @meeting = ConsulAssemblies::Meeting.find(params[:id])
    end

    def create
      @meeting = ConsulAssemblies::Meeting.new(meeting_params.merge(user: current_user))
      if @meeting.save
        redirect_to admin_meetings_path(assembly_id: @meeting.assembly_id), notice: t('.meeting_created')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end

    def destroy
      @meeting = ConsulAssemblies::Meeting.find(params[:id])
      @meeting.destroy

      redirect_to admin_meetings_path(assembly_id: @meeting.assembly_id), notice: t('.meeting_destroyed')
    end

    def update

      @meeting = ConsulAssemblies::Meeting.find(params[:id])
      if @meeting.update(meeting_params)

        redirect_to admin_meetings_path(assembly_id: @meeting.assembly_id), notice: t('.meeting_updated')
      else
        flash.now[:error] = t('admin.site_customization.pages.create.error')
        render :new
      end
    end


    def index
       @meetings = @assembly ? @assembly.meetings : ConsulAssemblies::Meeting
       @meetings = @meetings.order(scheduled_at: 'desc').page(params[:page] || 1)
    end

    private

    def load_meeting
      @meeting = ConsulAssemblies::Meeting.find(params[:id])
    end

    def load_assembly
      @assembly = ConsulAssemblies::Assembly.find(params[:assembly_id]) if params[:assembly_id]
    end

    def load_assemblies
      @assemblies = ConsulAssemblies::Assembly.order(:name)
    end

    def meeting_params
      params.require(:meeting).permit(
        :title,
        :summary,
        :description,
        :assembly_id,
        :scheduled_at,
        :close_accepting_proposals_at,
        :about_venue,
        :published_at,
        :attachment,
        :remove_attachment,
        :comments_count,
        :attendants_text,
        :accepts_proposals,
        :will_generate_acts,
        attachments_attributes: [:file, :file_cache, :title,:featured_image_flag, :_destroy, :id],
        previous_meeting_acceptance_proposals_attributes: [:attachment, :attachment_cache, :title, :_destroy, :id]
      )
    end
  end
end
