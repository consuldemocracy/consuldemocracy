class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  # Funciones y filtros para los usuarios
  before_action :actual_users, only: [:show, :edit]
  has_filters %w[id name], only: [:edit, :new]

    # Funciones para cargar los usuarios
  def actual_users
    @project_users = []
    @users_actuales = PageParticipant.where(site_customization_pages_id: @page.id).order(user_id: :asc)
    @users_actuales.each do |item|
      @project_users += User.where(id: item.user_id)
    end
    @project_users
  end

  def load_components(filter)
    arr_users = []
    @except_users = actual_users()
    @except_users.each do |item|
      arr_users << item.id
    end
    if filter == 'name'
      @users = User.where.not(id: arr_users).order(username: :asc)
    else filter == 'id'
      @users = User.where.not(id: arr_users).order(id: :desc)
    end
  end

  def load_all(filter)
    if filter == 'name'
      @users = User.all.order(username: :asc)
    else filter == 'id'
      @users = User.all.order(id: :desc)
    end
    @project_users = []
  end
  # Fin

  def index
    @pages = SiteCustomization::Page.order("slug").page(params[:page])
  end

  def new
    @page = SiteCustomization::Page.new
    load_all(@current_filter)
  end

  def edit
    load_components(@current_filter)
  end

  def create
    if @page.save

      user_elements = params[:user_ids]
      @page.save_component(user_elements)

      notice = t("admin.site_customization.pages.create.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.create.error")
      render :new
    end
  end

  def update
    if @page.update(page_params)

      user_elements = params[:user_ids]
      @page.save_component(user_elements)

      delete_user_elements = params[:delete_user_ids]
      @page.delete_component(delete_user_elements)

      notice = t("admin.site_customization.pages.update.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  def destroy
    @page.destroy!
    notice = t("admin.site_customization.pages.destroy.notice")
    redirect_to admin_site_customization_pages_path, notice: notice
  end

  private
    #JHH: Aquí se añade el campo de participantes de las páginas
    def page_params
      attributes = [:public, :slug, :more_info_flag, :print_content_flag, :status]

      params.require(:site_customization_page).permit(*attributes, :imagen,
        translation_params(SiteCustomization::Page), delete_user_ids: [], user_ids: []
      )
    end

    def resource
      SiteCustomization::Page.find(params[:id])
    end
end
