class Layout::CookiesConsent::BannerComponent < ApplicationComponent
  delegate :cookies, to: :helpers

  def render?
    feature?(:cookies_consent) && cookies_consent_unset?
  end

  def more_info_link
    Setting["cookies_consent.more_info_link"]
  end

  private

    def cookies_consent_unset?
      current_value.blank?
    end

    def current_value
      # cookies["cookies_consent"]
      cookies["cookies_consent#{version_name}"]
    end

    def version_name
      Setting["cookies_consent.version_name"]
    end
end
