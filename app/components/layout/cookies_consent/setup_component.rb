class Layout::CookiesConsent::SetupComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end

  private

    def more_info_link
      Setting["cookies_consent.more_info_link"]
    end
end
