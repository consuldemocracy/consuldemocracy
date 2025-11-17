require "rails_helper"

describe Layout::FooterComponent do
  describe "description links" do
    it "generates links that open in the same tab" do
      Setting["instance_repository_url"] = "https://example.com/my-fork/consuldemocracy"

      render_inline Layout::FooterComponent.new

      page.find(".info") do |info|
        expect(info).to have_css "a", count: 3
        expect(info).to have_css "a[rel~=nofollow]", count: 3
        expect(info).to have_css "a[rel~=external]", count: 3
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

  describe "instance repository link" do
    context "when instance_repository_url is present" do
      before { Setting["instance_repository_url"] = "https://example.com/my-fork/consuldemocracy" }

      it "renders the description with a link to the repository" do
        render_inline Layout::FooterComponent.new

        page.find(".info") do
          expect(page).to have_link "this repository", href: "https://example.com/my-fork/consuldemocracy"
        end
      end
    end

    context "when instance_repository_url is blank" do
      before { Setting["instance_repository_url"] = "" }

      it "does not render the instance repository sentence" do
        render_inline Layout::FooterComponent.new

        page.find(".info") do
          expect(page).not_to have_link "this repository"
        end
      end
    end
  end
end
