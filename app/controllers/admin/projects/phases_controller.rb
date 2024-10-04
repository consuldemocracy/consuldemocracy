class Admin::Projects::PhasesController < Admin::BaseController
  include Translatable
  include ImageAttributes
  load_and_authorize_resource :project, class: "Project"

  def show
    @project_phase = @project.phases.find(params[:id])
  end

  def new
    @project_phase = @project.phases.new( order: @project.next_phase_order )
    # @project_phase = Project::Phase.new(@projects)
  end

  def edit
    @project_phase = @project.phases.find(params[:id])
  end

  def create
    @project_phase = @project.phases.create(phase_params)

    if @project_phase.save
      notice = t("admin.projects.phases.create.notice")
      redirect_to [:admin, @project], notice: notice
    else
      render :new
    end
  end

  def update
    @project_phase = @project.phases.find(params[:id])
    if @project_phase.update(phase_params)
      redirect_to admin_project_path(@project), notice: t("admin.projects.phases.update.notice")
    else
      flash.now[:error] = t("admin.projects.phases.update.error")
      render :edit
    end
  end

  def destroy
    @project_phase = @project.phases.find(params[:id])
    @project_phase.destroy!
    redirect_to admin_project_path(@project)
  end

  private
    def resource_model
      Project::Phase
    end  
    def phase_params
      params.require(:project_phase).permit(allowed_params)
    end

    def allowed_params
      attributes = [:order, :enabled, :starts_at, :ends_at , image_attributes: image_attributes]

      [*attributes, translation_params(Project::Phase)]
    end

    def index_path
      admin_project_path(@project)
    end
end
