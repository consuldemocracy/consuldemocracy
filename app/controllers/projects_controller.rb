class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  skip_authorization_check

  before_action :load_components, only: [:edit, :new, :update]
  before_action :actual_debates, :actual_pages, only: [:show]

  # Función para mostrar los debates actuales en el proyecto
  def actual_debates
    @project_debates = []
    @debates_actuales = DebateOnProject.where(project_id: @project.id).order(debate_id: :asc)
    @debates_actuales.each do |item|
      @project_debates += Debate.where(id: item.debate_id)
    end
    @project_debates
  end

  # Función para mostrar las páginas actuales en el proyecto
  def actual_pages
    @project_pages = []
    @pages_actuales = PageOnProject.where(project_id: @project.id).order(site_customization_page_id: :asc)
    @pages_actuales.each do |item|
      @project_pages += SiteCustomization::Page.where(id: item.site_customization_page_id)
    end
    @project_pages
  end

  # def load_pages
  #   @pages = SiteCustomization::Page.all
  # end

  #Cargar los componentes a añadir en el proyecto
  def load_components
    @pages = SiteCustomization::Page.all
    @debates = Debate.all
    @users = User.all
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
      
      # #Guarda las páginas
      # page_elements = params[:page_ids]
      # @project.save_pages(page_elements)

      #Guarda los debates
      page_elements = params[:page_ids]
      debate_elements = params[:debate_ids]
      user_elements = params[:user_ids]
      @project.save_component(page_elements, debate_elements, user_elements)

      # #Guarda los usuarios
      # user_elements = params[:user_ids]
      # @project.save_users(user_elements)

      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      
      page_elements = params[:page_ids]
      debate_elements = params[:debate_ids]
      user_elements = params[:user_ids]
      @project.save_component(page_elements, debate_elements, user_elements)

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
      params.require(:project).permit(:title, :user_elements, :debate_elements, :page_elements, page_ids: [] , user_ids: [] , debate_ids: [] )
    end
end
