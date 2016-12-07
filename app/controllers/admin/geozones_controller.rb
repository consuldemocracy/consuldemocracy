class Admin::GeozonesController < Admin::BaseController

  respond_to :html
  
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    @geozone = Geozone.new(geozone_params)

    if @geozone.save
      redirect_to admin_geozones_path
    else
      render :new
    end
  end

  private

    def geozone_params
      params.require(:geozone).permit(:name, :external_code, :census_code)
    end
end
