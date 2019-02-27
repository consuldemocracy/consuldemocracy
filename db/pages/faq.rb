if SiteCustomization::Page.find_by_slug("faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  page.title = I18n.t("pages.help.faq.page.title")
  page.content = "<div class='row margin-top'>
                    <div class='menu small-12 medium-3 column'>
                      <ul class='menu vertical margin-top'>
                        <li>
                          <a href='#1'>
                            <strong>
                              #{I18n.t("pages.help.faq.page.faq_1_title")}
                            </strong>
                          </a>
                        </li>
                      </ul>
                    </div>

                    <div class='text small-12 medium-9 column'>

                      <p>#{I18n.t("pages.help.faq.page.description")}</p>

                      <h2 id='1'>#{I18n.t("pages.help.faq.page.faq_1_title")}</h2>
                      <p>#{I18n.t("pages.help.faq.page.faq_1_description")}</p>
                    </div>
                  </div>"
  page.save!
end
