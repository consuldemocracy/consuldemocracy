class Admin::GeozonesController < Admin::BaseController

  respond_to :html
  
  load_and_authorize_resource

  def index
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
  private

    def geozone_params
      params.require(:geozone).permit(:name, :external_code, :census_code)
    end
end
