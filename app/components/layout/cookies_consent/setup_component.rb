class Layout::CookiesConsent::SetupComponent < Layout::CookiesConsent::BaseComponent
  delegate :cookies, to: :helpers

  def render?
    super && feature?("cookies_consent.setup_page")
  end

  def notice
    CGI::escapeHTML(render Layout::CalloutComponent.new(id: "cookies-settings-callout",
                                                        message: t("cookies_consent.notice")))
  end

  def vendors
    Cookies::Vendor.all
  end

  private

    def more_info_link
      Setting["cookies_consent.more_info_link"]
    end
end
