require "rails_helper"

describe Layout::LegalLinksComponent do
  describe "link to manage cookies" do
    it "shows a link to the cookies management modal when the cookies consent is enabled" do
      Setting["feature.cookies_consent"] = true

      render_inline Layout::LegalLinksComponent.new

      expect(page).to have_css "a[data-open=cookies_consent_management]", text: "Manage cookies"
    end

    it "does not show a link to the cookies management modal when the cookies consent is disabled" do
      Setting["feature.cookies_consent"] = false

      render_inline Layout::LegalLinksComponent.new

      expect(page).not_to have_content "Manage cookies"
    end
  end
end
