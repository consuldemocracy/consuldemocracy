class Admin::GeographiesController < Admin::BaseController

  before_action :set_geography, only: [:show, :edit, :update, :destroy]
  before_action :set_headings, only: [:new, :edit, :update, :create]

  respond_to :html, :js

  def index
    @geographies = Geography.all.order("LOWER(name)")
  end

  def new
    @geography = Geography.new
    #@headings = Budget::Heading.all
  end

  def edit
  end

  def create
    @geography = Geography.new(geography_params)

    if @geography.save
      redirect_to admin_geographies_path, notice: 'Geography was successfully created.'
    else
      render :new
    end
  end

  def update
    if @geography.update(geography_params)
      reset_outline_points
      redirect_to admin_geographies_path, notice: 'Geography was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @geography.destroy
    redirect_to admin_geographies_path, notice: t('admin.geozones.delete.success')
  end

  private

    def set_geography
      @geography = Geography.find(params[:id])
    end

    def set_headings
      @headings = Budget::Heading.order(:name)
    end

    def geography_params
      documents_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
      params.require(:geography).permit(:name, heading_ids: [], documents_attributes: documents_attributes)
    end

    def reset_outline_points
      if not @geography.documents.any?
        @geography.outline_points = []
      end
      @geography.save
    end

end
