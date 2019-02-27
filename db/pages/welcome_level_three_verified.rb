if SiteCustomization::Page.find_by_slug("welcome_level_three_verified").nil?
  page = SiteCustomization::Page.new(slug: "welcome_level_three_verified", status: "published")
  page.title = I18n.t("welcome.welcome.title")

  page.content = "<div class='user-permissions'>
                    <p>#{I18n.t("welcome.welcome.user_permission_info")}</p>

                    <ul>
                      <li><span class='icon-check'></span>&nbsp;
                        #{I18n.t("welcome.welcome.user_permission_debates")}</li>
                      <li><span class='icon-check'></span>&nbsp;
                        #{I18n.t("welcome.welcome.user_permission_proposal")}</li>
                      <li><span class='icon-check'></span>&nbsp;
                        #{I18n.t("welcome.welcome.user_permission_support_proposal")}</li>
                      <li><span class='icon-check'></span>&nbsp;
                        #{I18n.t("welcome.welcome.user_permission_votes")}</li>
                    </ul>

                    <p><span>#{I18n.t("welcome.welcome.user_permission_verify_info")}</span></p>

                    <p>#{I18n.t("welcome.welcome.user_permission_verify")}</p>

                    <p class='already-verified'>
                      <span class='icon-check'></span>
                        #{I18n.t("account.show.verified_account")}
                    </p>

                    <p><a href='/'>#{I18n.t("welcome.welcome.go_to_index")}</a></p>
                  </div>"
  page.save!
end
