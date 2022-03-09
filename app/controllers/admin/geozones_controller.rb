class Admin::GeozonesController < Admin::BaseController
  respond_to :html

  load_and_authorize_resource

  def index
    @geozones = Geozone.all.order(Arel.sql("LOWER(name)"))
  end

  def new
  end

  def edit
  end

  def create
    @geozone = Geozone.new(geozone_params)

    if @geozone.save
      redirect_to admin_geozones_path
    else
      render :new
    end
  end

  def update
    if @geozone.update(geozone_params)
      redirect_to admin_geozones_path
    else
      render :edit
    end
  end

  def destroy
    if @geozone.safe_to_destroy?
      @geozone.destroy!
      redirect_to admin_geozones_path, notice: t("admin.geozones.delete.success")
    else
      redirect_to admin_geozones_path, flash: { error: t("admin.geozones.delete.error") }
    end
  end

  private

    def geozone_params
      params.require(:geozone).permit(:name, :external_code, :census_code, :html_map_coordinates)
    end
end
