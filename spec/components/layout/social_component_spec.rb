require "rails_helper"

describe Layout::SocialComponent do
  describe "#render?" do
    it "renders when a social setting is present" do
      Setting["twitter_handle"] = "myhandle"

      render_inline Layout::SocialComponent.new

      expect(page).to have_css "ul"
    end

    it "renders when a content block is present" do
      Setting["twitter_handle"] = ""
      Setting["facebook_handle"] = ""
      Setting["youtube_handle"] = ""
      Setting["telegram_handle"] = ""
      Setting["instagram_handle"] = ""

      create(:site_customization_content_block, name: "footer")

      render_inline Layout::SocialComponent.new

      expect(page).to have_css "ul"
    end

    it "does not render with no settings present and no content block present" do
      Setting["twitter_handle"] = ""
      Setting["facebook_handle"] = ""
      Setting["youtube_handle"] = ""
      Setting["telegram_handle"] = ""
      Setting["instagram_handle"] = ""

      render_inline Layout::SocialComponent.new

      expect(page).not_to be_rendered
    end
  end
end
