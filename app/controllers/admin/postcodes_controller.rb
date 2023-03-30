class Admin::PostcodesController < Admin::BaseController
  respond_to :html

  load_and_authorize_resource

  def index
    @postcodes = Postcode.all.order(Arel.sql("UPPER(postcode)"))
  end

  def new
  end

  def edit
  end

  def create
    @postcode = Postcode.new(postcode_params)

    if @postcode.save
      redirect_to admin_postcodes_path
    else
      render :new
    end
  end

  def update
    if @postcode.update(postcode_params)
      redirect_to admin_postcodes_path
    else
      render :edit
    end
  end

  def destroy
    if @postcode.safe_to_destroy?
      @postcode.destroy!
      redirect_to admin_postcodes_path, notice: t("admin.postcodes.delete.success")
    else
      redirect_to admin_postcodes_path, flash: { error: t("admin.postcodes.delete.error") }
    end
  end

  private

    def postcode_params
      params.require(:postcode).permit(allowed_params)
    end

    def allowed_params
      [:name, :geozone, :ward, ]
    end
end
