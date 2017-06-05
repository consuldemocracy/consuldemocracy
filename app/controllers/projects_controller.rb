class ProjectsController < ApplicationController
  skip_authorization_check
  load_and_authorize_resource
  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def create
    if @project.save
      redirect_to admin_projects_url, notice: t("flash.actions.create.problem")
    else
      render :new
    end
  end

  def edit
    @project.design_events.build
  end

  def update
    if @project.update(project_params)
      redirect_to admin_projects_url, notice: t("flash.actions.update.project")
    else
      render :edit
    end
  end

  def destroy
  end

private
  def load_geozones
    @geozones = Geozone.all.order(:name)
  end

  def project_params
    params.require(:project).permit(:name, :description, :starts_at, :ends_at, :proposal_id, :geozone_restricted, geozone_ids: [], design_events_attributes: [:starts_at, :name, :place, :pax] )
  end

end
