class Admin::Dashboard::IndexComponent < ApplicationComponent
  include Header

  def title
    t("admin.dashboard.index.title")
  end

  private

    def info
      sanitize t("admin.dashboard.index.info")
    end

    def email_link
      mail_to "info@consulfoundation.org"
    end

    def website_link
      link_to "https://consuldemocracy.org", "https://consuldemocracy.org"
    end
end
