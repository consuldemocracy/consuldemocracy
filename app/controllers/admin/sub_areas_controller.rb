class Admin::SubAreasController < Admin::BaseController
  include FeatureFlags

  feature_flag :sub_areas

  before_action :set_sub_area, except: [:new, :create]
  before_action :set_area

  # GET /sub_areas/new
  def new
    @sub_area = SubArea.new
  end

  # GET /sub_areas/1/edit
  def edit
  end

  # POST /sub_areas
  def create
    @sub_area = SubArea.new(sub_area_params)
    if @sub_area.save
      redirect_to edit_admin_area_path(@area)
    else
      render :new
    end
  end

  # PATCH/PUT /sub_areas/1
  def update
    if @sub_area.update(sub_area_params)
      redirect_to edit_admin_area_path(@area)
    else
      render :edit
    end
  end

  # DELETE /sub_areas/1
  def destroy
    @sub_area.destroy
    redirect_to edit_admin_area_path(@area)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sub_area
      @sub_area = SubArea.find(params[:id])
    end

    def set_area
      @area = Area.find(params[:area_id])
    end

    # Only allow a trusted parameter "white list" through.
    def sub_area_params
      params.require(:sub_area)
            .permit(:area_id, translations_attributes: [:id, :name, :area_id, :locale,
                                              :_destroy])
    end
end
