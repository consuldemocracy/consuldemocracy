class RestrictAdminIps
  attr_reader :ip

  def initialize(ip)
    @ip = ip
  end

  def allowed?
    unrestricted_access? || allowed_ip?
  end

  private

    def unrestricted_access?
      allowed_ips.blank?
    end

    def allowed_ips
      Array(Tenant.current_secrets.dig(:security, :allowed_admin_ips))
    end

    def allowed_ip?
      normalized_allowed_ips.any? { |allowed_ip| allowed_ip.include?(ip) }
    rescue IPAddr::Error
      false
    end

    def normalized_allowed_ips
      allowed_ips.map do |allowed_ip|
        IPAddr.new(allowed_ip)
      rescue IPAddr::Error
        Rails.logger.warn "Your allowed_admin_ips configuration includes the " \
                          "address \"#{allowed_ip}\", which is not valid"
        nil
      end.compact
    end
end
