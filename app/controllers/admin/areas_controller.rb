class Admin::AreasController < Admin::BaseController
  include FeatureFlags

  feature_flag :areas

  before_action :set_area, only: [:edit, :update, :destroy]

  # GET /areas
  def index
    @areas = Area.includes(:translations, :sub_areas).all
  end

  # GET /areas/new
  def new
    @area = Area.new
  end

  # GET /areas/1/edit
  def edit
    @sub_areas = @area.sub_areas
  end

  # POST /areas
  def create
    @area = Area.new(area_params)

    if @area.save
      redirect_to admin_areas_path
    else
      render :new
    end
  end

  # PATCH/PUT /areas/1
  def update
    if @area.update(area_params)
      redirect_to admin_areas_path
    else
      render :edit
    end
  end

  # DELETE /areas/1
  def destroy
    @area.destroy
    redirect_to admin_areas_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_area
      @area = Area.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def area_params
      params.require(:area).permit(translations_attributes: [:id, :name,
                                                             :locale,
                                                             :_destroy],
                                   image_attributes: [:id, :title, :attachment,
                                                      :cached_attachment,
                                                      :user_id, :_destroy])
    end
end
