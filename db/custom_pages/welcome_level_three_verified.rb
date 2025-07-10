if SiteCustomization::Page.find_by(slug: "welcome_level_three_verified").nil?
  page = SiteCustomization::Page.new(slug: "welcome_level_three_verified", status: "published")
  page.title = I18n.t("welcome.welcome.title")

  page.content = "<p>#{I18n.t("welcome.welcome.user_permission_info")}</p>
                  <ul>
                    <li>#{I18n.t("welcome.welcome.user_permission_debates")}</li>
                    <li>#{I18n.t("welcome.welcome.user_permission_proposal")}</li>
                    <li>#{I18n.t("welcome.welcome.user_permission_support_proposal")}</li>
                    <li>#{I18n.t("welcome.welcome.user_permission_votes")}</li>
                  </ul>

                  <p>#{I18n.t("welcome.welcome.user_permission_verify_info")}</p>

                  <p>#{I18n.t("account.show.verified_account")}</p>

                  <p><a href='#{Rails.application.config.root_directory}'>#{I18n.t("welcome.welcome.start_using_consul")}</a></p>"
  page.save!
end
