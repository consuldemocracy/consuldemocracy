module RestrictIp
  extend ActiveSupport::Concern

  included do
    before_action :restrict_ip
  end

private

  # Default empty allowed IPs, meaning unrestricted access by default
  DEFAULT_ALLOWED_IPS = [].freeze

  def restrict_ip
    if restricted_access? && !allowed_ip?(request.remote_ip)
      flash[:alert] = "Access denied. Your IP address is not allowed."
      redirect_to root_path
    end
  end

  def restricted_access?
    # Check if secrets contain a non-empty allowed_ips
    allowed_ips = Tenant.current_secrets.allowed_ips
    allowed_ips.present?
  end

  def allowed_ip?(ip)
    allowed_ips = Rails.application.secrets.allowed_ips || DEFAULT_ALLOWED_IPS

    # Ensure allowed_ips is an array
    allowed_ips = Array(allowed_ips)

    allowed_ips.any? do |allowed_ip|
      IPAddr.new(allowed_ip).include?(ip)
    end
  rescue IPAddr::Error
    # Handle invalid IP formats if any
    false
  end
end
