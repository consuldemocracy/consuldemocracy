class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  skip_authorization_check

  before_action :load_pages, :load_components, only: [:edit, :new, :update]
  before_action :actual_debates, :actual_pages, only: [:show]

  def actual_debates
    @project_debates = []
    @debates_actuales = DebateOnProject.where(project_id: @project.id).order(debate_id: :asc)
    @debates_actuales.each do |item|
      @project_debates += Debate.where(id: item.debate_id)
    end
    @project_debates
  end

  def actual_pages
    @project_pages = []
    @pages_actuales = PageOnProject.where(project_id: @project.id).order(site_customization_page_id: :asc)
    @pages_actuales.each do |item|
      @project_pages += SiteCustomization::Page.where(id: item.site_customization_page_id)
    end
    @project_pages
  end

  def load_pages
    @pages = SiteCustomization::Page.all
  end

  def load_components
    @debates = Debate.all
  end

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      
      #Guarda las páginas
      page_elements = params[:page_ids]
      @project.save_pages(page_elements)

      #Guarda los componentes
      debate_elements = params[:debate_ids]
      @project.save_component(debate_elements)

      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      #Guarda las páginas
      page_elements = params[:page_ids]
      @project.save_pages(page_elements)

      #Guarda los componentes
      debate_elements = params[:debate_ids]
      @project.save_component(debate_elements)

      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy_component
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params.require(:project).permit(:title, :debate_elements, :page_elements, page_ids: [] , debate_ids: [] )
    end
end
