module IpDeniedHandler
  extend ActiveSupport::Concern

  included do
    before_action :restrict_ip, unless: :allowed_ip?
  end

private

  def restrict_ip
    redirect_to root_path, alert: t("ip_denied_handler.unauthorized")
  end

  def allowed_ip?
    RestrictAdminIps.new(request.remote_ip).allowed?
  end
end
