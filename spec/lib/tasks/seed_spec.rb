require "rails_helper"

describe "rake db:seed" do
  it "generates all custom pages translations populated by db:seeds" do
    default_locales = I18n.available_locales
    begin
      I18n.available_locales = [:ar, :bg, :bs, :ca, :cs, :da, :de, :el, :en, :es, :"es-PE", :eu, :fa, :fr,
        :gl, :he, :hr, :id, :it, :ka, :nl, :oc, :pl, :"pt-BR",
        :ro, :ru, :sl, :sq, :so, :sr, :sv, :tr, :val, :"zh-CN", :"zh-TW"]
      SiteCustomization::Page.destroy_all
      load Rails.root.join("db", "pages.rb")

      paths = { accessibility: "pages.accessibility.title", conditions: "pages.conditions.title",
                faq: "pages.help.faq.page.title", privacy: "pages.privacy.title",
                welcome_not_verified: "welcome.welcome.title",
                welcome_level_two_verified: "welcome.welcome.title",
                welcome_level_three_verified: "welcome.welcome.title" }

      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          paths.each do |slug, path|
            site = SiteCustomization::Page.find_by(slug: slug).translations.find_by(locale: locale)
            expect(site.title).to eq I18n.t(path)
          end
        end
      end
    ensure
      I18n.available_locales = default_locales
    end
  end
end
