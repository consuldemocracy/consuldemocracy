class Admin::ProjectsController < Admin::BaseController
  include Translatable
  include ImageAttributes
  include HasOrders

  has_orders %w[created_at]

  def index
    @projects = Project.sort_by_created.all
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
  end

  def show
    @project = Project.find(params[:id])
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      notice = t("admin.projects.create.notice")
      redirect_to [:admin, @project], notice: notice
    else
      render :new
    end
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: t("admin.projects.update.notice")
    else
      flash.now[:error] = t("admin.projects.update.error")
      render :edit
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy!
    redirect_to admin_projects_path
  end

  private
    def resource_model
      Project
    end  
    def project_params
      params.require(:project).permit(allowed_params)
    end

    def allowed_params
      attributes = [:state, :slug, image_attributes: image_attributes]

      [*attributes, translation_params(Project)]
    end
end
