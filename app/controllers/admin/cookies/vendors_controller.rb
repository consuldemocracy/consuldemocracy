class Admin::Cookies::VendorsController < Admin::BaseController
  load_and_authorize_resource :vendor, class: "::Cookies::Vendor"

  def create
    if @vendor.save
      redirect_to admin_settings_path(anchor: "tab-cookies-consent"),
                  notice: t("admin.cookies.vendors.create.notice")
    else
      render :new
    end
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to admin_settings_path(anchor: "tab-cookies-consent"),
                  notice: t("admin.cookies.vendors.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @vendor.destroy!

    redirect_to admin_settings_path(anchor: "tab-cookies-consent"),
                notice: t("admin.cookies.vendors.destroy.notice")
  end

  private

    def vendor_params
      params.require(:cookies_vendor).permit(allowed_params)
    end

    def allowed_params
      [:name, :description, :cookie, :script]
    end
end
