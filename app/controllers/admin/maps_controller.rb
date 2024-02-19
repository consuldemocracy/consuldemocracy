class Admin::MapsController < Admin::BaseController
  before_action :load_maps, only: :index
  before_action :load_map, only: :destroy

  def new
    @map = Map.new
  end

  def create
    @map = Map.new(map_params)

    if @map.save
      create_map_location
      redirect_to edit_admin_map_map_location_path(@map, @map.map_location), notice: t("admin.maps.flash.create")
    else
      render :new
    end
  end

  def destroy
    @map.map_location&.destroy!
    @map.destroy!
    redirect_to admin_maps_path, notice: t("admin.maps.flash.destroy")
  end

  private

    def load_maps
      @maps = Map.all.order(id: :desc)
    end

    def load_map
      @map = Map.find(params[:id])
    end

    def map_params
      params.require(:map).permit(:budget_id)
    end

    def create_map_location
      MapLocation.new(map_id: @map.id).from_map(Map.default).save!
    end
end
