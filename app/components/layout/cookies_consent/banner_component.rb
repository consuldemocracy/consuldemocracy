class Layout::CookiesConsent::BannerComponent < Layout::CookiesConsent::BaseComponent
  delegate :cookies, to: :helpers

  def render?
    super && cookies_consent_unset?
  end

  private

    def cookies_consent_unset?
      cookies["cookies_consent_#{version_name}"].blank?
    end
end
