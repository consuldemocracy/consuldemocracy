class Layout::CookiesConsent::BannerComponent < Layout::CookiesConsent::BaseComponent
  delegate :cookies, to: :helpers
  delegate :current_user, to: :helpers

  def render?
    super && missing_cookies_setup?
  end

  def more_info_link
    Setting["cookies_consent.more_info_link"]
  end

  private

    def missing_cookies_setup?
      current_value.blank?
    end

    def current_value
      cookies["cookies_consent#{version_name}"]
    end
end
