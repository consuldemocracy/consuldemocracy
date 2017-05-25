class Admin::ProjectsController < Admin::BaseController
  load_and_authorize_resource
  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def show
  end

  def index
  end

  def new
  end

  def create
    if @project.save
      redirect_to admin_projects_url, notice: t("flash.actions.create.problem")
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

private
  def load_geozones
    @geozones = Geozone.all.order(:name)
  end

  def project_params
    params.require(:project).permit(:name, :description, :starts_at, :ends_at, :proposal_id, :geozone_restricted, geozone_ids: [])
  end

end
