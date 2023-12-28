class Layout::CookiesConsent::BannerComponent < ApplicationComponent
  delegate :cookies, to: :helpers

  def render?
    feature?(:cookies_consent) && missing_cookies_setup?
  end

  private

    def missing_cookies_setup?
      cookies["cookies_consent"].blank?
    end
end
