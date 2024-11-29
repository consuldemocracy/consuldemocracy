class Layout::CookiesConsent::BannerComponent < Layout::CookiesConsent::BaseComponent
  delegate :cookies, to: :helpers

  def render?
    super && cookies_consent_unset?
  end

  def more_info_link
    Setting["cookies_consent.more_info_link"]
  end

  private

    def cookies_consent_unset?
      cookies["cookies_consent"].blank?
    end
end
