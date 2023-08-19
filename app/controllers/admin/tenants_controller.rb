class Admin::TenantsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @tenants = @tenants.order(:name)
  end

  def new
  end

  def edit
  end

  def create
    if @tenant.save
      update_default_tenant_administrator
      redirect_to admin_tenants_path, notice: t("admin.tenants.create.notice")
    else
      render :new
    end
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to admin_tenants_path, notice: t("admin.tenants.update.notice")
    else
      render :edit
    end
  end

  def hide
    @tenant.hide

    respond_to do |format|
      format.html { redirect_to admin_tenants_path, notice: t("admin.tenants.hide.notice") }
      format.js { render template: "admin/tenants/toggle_enabled" }
    end
  end

  def restore
    @tenant.restore

    respond_to do |format|
      format.html { redirect_to admin_tenants_path, notice: t("admin.tenants.restore.notice") }
      format.js { render template: "admin/tenants/toggle_enabled" }
    end
  end

  private

    def tenant_params
      params.require(:tenant).permit(:name, :schema, :schema_type)
    end

    def update_default_tenant_administrator
      tenant_administrator_credentials = {
        email: current_user.email,
        username: current_user.username,
        encrypted_password: current_user.encrypted_password
      }

      Tenant.switch(@tenant.schema) do
        default_admin_account = User.administrators.first
        default_admin_account.skip_confirmation_notification!
        default_admin_account.update!(tenant_administrator_credentials)
        default_admin_account.confirm
      end
    end
end
