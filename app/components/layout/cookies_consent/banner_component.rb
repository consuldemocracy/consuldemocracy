class Layout::CookiesConsent::BannerComponent < ApplicationComponent
  delegate :cookies, to: :helpers

  def render?
    feature?(:cookies_consent) && cookies_consent_unset?
  end

  def notice
    CGI::escapeHTML(render Layout::CalloutComponent.new(id: "cookies-settings-callout",
                                                        message: t("cookies_consent.notice")))
  end

  private

    def cookies_consent_unset?
      cookies["cookies_consent"].blank?
    end
end
