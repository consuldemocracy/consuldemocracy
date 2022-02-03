class Admin::MapLocationsController < Admin::BaseController
  before_action :load_map_location

  def update
    if @map_location.update(map_location_params)
      flash[:notice] = t("admin.maps.flash.update")
    end
    render :edit
  end

  def update_from_map
    if @map_location.update(latitude: params[:latitude],
                            longitude: params[:longitude],
                            zoom: params[:zoom])
      flash[:notice] = t("admin.maps.flash.update")
    end
    render :edit
  end

  private

    def load_map_location
      @map = ::Map.find(params[:map_id])
      @map_location = @map.map_location
    end

    def map_location_params
      params.require(:map_location).permit(:latitude, :longitude, :zoom)
    end
end
