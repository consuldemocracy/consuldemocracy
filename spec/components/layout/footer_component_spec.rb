require "rails_helper"

describe Layout::FooterComponent do
  describe "description links" do
    it "generates links that open in the same tab" do
      render_inline Layout::FooterComponent.new

      page.find(".info") do |info|
        expect(info).to have_css "a", count: 2
        expect(info).to have_css "a[rel~=nofollow]", count: 2
        expect(info).to have_css "a[rel~=external]", count: 2
        expect(info).not_to have_css "a[target]"
      end
    end
  end

  it "is not rendered when multitenancy_management_mode is enabled" do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)
    render_inline Layout::FooterComponent.new

    expect(page).not_to be_rendered
  end

  describe "when the cookies consent feature is enabled" do
    before { Setting["feature.cookies_consent"] = true }

    it "shows a link to the cookies setup modal when the cookies setup page is enabled" do
      Setting["cookies_consent.setup_page"] = true

      render_inline Layout::FooterComponent.new

      page.find(".subfooter") do |subfooter|
        expect(subfooter).to have_css "a[data-open=cookies_consent_setup]", text: "Cookies setup"
      end
    end

    it "does not show a link to the cookies setup modal when the cookies setup page is disabled" do
      Setting["cookies_consent.setup_page"] = false

      render_inline Layout::FooterComponent.new

      page.find(".subfooter") do |subfooter|
        expect(subfooter).not_to have_css "a[data-open=cookies_consent_setup]", text: "Cookies setup"
      end
    end
  end
end
