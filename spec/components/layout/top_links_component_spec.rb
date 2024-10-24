require "rails_helper"

describe Layout::TopLinksComponent do
  describe "#render?" do
    it "renders when a content block is defined" do
      create(:site_customization_content_block, name: "top_links")

      render_inline Layout::TopLinksComponent.new

      expect(page).to have_css "ul"
    end

    it "does not render when no content block is defined" do
      render_inline Layout::TopLinksComponent.new

      expect(page).not_to be_rendered
    end
  end
end
