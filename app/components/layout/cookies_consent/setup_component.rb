class Layout::CookiesConsent::SetupComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end

  def vendors
    Cookies::Vendor.all
  end

  def version_name
    Setting["cookies_consent.version_name"]
  end

  private

    def more_info_link
      Setting["cookies_consent.more_info_link"]
    end
end
