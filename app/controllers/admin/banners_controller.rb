class Admin::BannersController < Admin::BaseController

  has_filters %w{all with_active with_inactive}, only: :index

  before_action :find_banner, only: [:edit, :update, :destroy]
  before_action :banner_styles, only: [:edit, :new, :create, :update]
  before_action :banner_imgs, only: [:edit, :new, :create, :update]

  respond_to :html, :js

  load_and_authorize_resource

  def index
    @banners = Banner.send(@current_filter).page(params[:page])
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      redirect_to admin_banners_path
    else
      render :new
    end
  end

  def update
    @banner.assign_attributes(banner_params)
    if @banner.update(banner_params)
      redirect_to admin_banners_path
    else
      render :edit
    end
  end

  def destroy
    @banner.destroy
    redirect_to admin_banners_path
  end

  private
    def banner_params
      params.require(:banner).permit(:title, :description, :target_url, :style, :image, :post_started_at, :post_ended_at)
    end

    def find_banner
      @banner = Banner.find(params[:id])
    end

    def banner_styles
      @banner_styles = Setting.all.banner_style.map { |banner_style| [banner_style.value, banner_style.key.split('.')[1]] }
    end

    def banner_imgs
      @banner_imgs = Setting.all.banner_img.map { |banner_img| [banner_img.value, banner_img.key.split('.')[1]] }
    end
end