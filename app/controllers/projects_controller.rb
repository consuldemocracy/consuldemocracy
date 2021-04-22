class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :is_admin?, except: [:show]
  skip_authorization_check

  before_action :load_components, only: [:edit, :update]
  before_action :load_all, only: [:new]
  before_action :actual_debates, :actual_pages, only: [:show, :edit]
  before_action :actual_users, only: [:edit, :show]

  def is_admin?
    if current_user.administrator?
      flash[:notice] = t "authorized.title"
    else
      redirect_to root_path
      flash[:alert] = t "not_authorized.title"
    end

  end

  def actual_users
    @project_users = []
    @users_actuales = UserOnProject.where(project_id: @project.id).order(user_id: :asc)
    @users_actuales.each do |item|
      @project_users += User.where(id: item.user_id)
    end
    @project_users
  end

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

  def load_all
    @pages = SiteCustomization::Page.all
    @debates = Debate.all
    @users = User.all
    @project_users = []
    @project_pages = []
    @project_debates = []
  end

  #Cargar los componentes a añadir en el proyecto
  def load_components
    # if params[:page_search]
    #   @pages = SiteCustomization::Page.search(params[:page_search])
    # else
    #   @pages = SiteCustomization::Page.all
    # end

    # if params[:debate_search]
    #   @debates = Debate.search(params[:debate_search])
    # else
    #   @debates = Debate.all
    # end
    arr_pages = []
    @except_pages = actual_pages()
    @except_pages.each do |item|
      arr_pages << item.id
    end
    @pages = SiteCustomization::Page.where.not(id: arr_pages).order(id: :asc)
    
    arr_debates = []
    @except_debates = actual_debates()
    @except_debates.each do |item|
      arr_debates << item.id
    end
    @debates = Debate.where.not(id: arr_debates).order(id: :asc)

    arr_users = []
    @except_users = actual_users()
    @except_users.each do |item|
      arr_users << item.id
    end
    @users = User.where.not(id: arr_users).order(id: :asc)
  end

  # GET /projects
  def index
    @projects = Project.all
    if params[:search]
     @projects = Project.search(params[:search])
    end
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

      #Guarda los componentes
      page_elements = params[:page_ids]
      debate_elements = params[:debate_ids]
      user_elements = params[:user_ids]
      @project.save_component(page_elements, debate_elements, user_elements)

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

      delete_page_elements = params[:delete_page_ids]
      delete_debate_elements = params[:delete_debate_ids]
      delete_user_elements = params[:delete_user_ids]
      @project.delete_component(delete_page_elements, delete_debate_elements, delete_user_elements)

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
      params.require(:project).permit(:search, :title, :user_elements, :debate_elements, :page_elements, page_ids: [] , user_ids: [] , debate_ids: [] , delete_debate_ids: [] , delete_user_ids: [] , delete_page_ids: [])
    end
end
