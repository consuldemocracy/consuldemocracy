class Layout::CookiesConsent::BaseComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end

  private

    def version_name
      Setting["cookies_consent.version_name"]
    end
end
