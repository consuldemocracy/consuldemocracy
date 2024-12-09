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

  describe "link to manage cookies" do
    it "shows a link to the cookies management modal when the cookies consent is enabled" do
      Setting["feature.cookies_consent"] = true

      render_inline Layout::FooterComponent.new

      page.find(".subfooter") do |footer|
        expect(footer).to have_css "a[data-open=cookies_consent_management]", text: "Manage cookies"
      end
    end

    it "does not show a link to the cookies management modal when the cookies consent is disabled" do
      Setting["feature.cookies_consent"] = false

      render_inline Layout::FooterComponent.new

      expect(page).not_to have_content "Manage cookies"
    end
  end
end
