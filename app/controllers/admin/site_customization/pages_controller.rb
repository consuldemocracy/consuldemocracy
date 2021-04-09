class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  #JHH:
  before_action :load_participants, :actual_people, only: [:edit, :new]

  def actual_people
    @people = []
    @page_actual_participant = PageParticipant.where(site_customization_pages_id: @page.id).order(user_id: :asc)
    @page_actual_participant.each do |part|
      @people += User.where(id: part.user_id)
    end
    @people
  end

  def load_participants
    arr = []
    @except = actual_people()
    @except.each do |index|
      arr << index.id
    end
    @participants = User.where.not(id: arr).order(id: :asc)
  end
  #Fin

  def index
    @pages = SiteCustomization::Page.order("slug").page(params[:page])
  end

  def create
    if @page.save
      notice = t("admin.site_customization.pages.create.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.create.error")
      render :new
    end
  end

  def update
    if @page.update(page_params)
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
      attributes = [:delete_users_id, :public, :page_users_id, :slug, :more_info_flag, :print_content_flag, :status]

      params.require(:site_customization_page).permit(*attributes, :imagen,
        translation_params(SiteCustomization::Page)
      )
    end

    def resource
      SiteCustomization::Page.find(params[:id])
    end
end
