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
      create_tenant_administrator
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

  private

    def tenant_params
      params.require(:tenant).permit(:name, :schema, :schema_type)
    end

    def create_tenant_administrator
      Tenant.switch(@tenant.schema) do
        admin = User.create!(username: current_user.username,
                             email: current_user.email,
                             password: "password_tmp",
                             password_confirmation: "password_tmp",
                             confirmed_at: Time.current,
                             terms_of_service: "1")
        admin.update!(password: nil,
                      password_confirmation: nil,
                      encrypted_password: current_user.encrypted_password)

        admin.create_administrator
      end
    end
end
