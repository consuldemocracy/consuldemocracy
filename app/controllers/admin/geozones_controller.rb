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

  def destroy
    # Check that in none of the other associated models talbes a record exists
    # referencing this geozone
    safe_to_destroy = true

    # safe_to_destroy &= Proposal.where(geozone: @geozone).empty?
    # safe_to_destroy &= Debate.where(geozone: @geozone).empty?
    # safe_to_destroy &= SpendingProposal.where(geozone: @geozone).empty?
    # safe_to_destroy &= User.where(geozone: @geozone).empty?

    Geozone.reflect_on_all_associations.each do |association|
      attached_model = association.klass
      safe_to_destroy &= attached_model.where(geozone: @geozone).empty?
    end

    if safe_to_destroy
      @geozone.destroy
      redirect_to admin_geozones_url, notice: t('admin.geozones.delete.success')
    else
      redirect_to admin_geozones_path, flash: { error: t('admin.geozones.delete.error') }
    end
  end

  private

    def geozone_params
      params.require(:geozone).permit(:name, :external_code, :census_code)
    end
end
