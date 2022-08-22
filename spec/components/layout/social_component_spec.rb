require "rails_helper"

describe Layout::SocialComponent do
  describe "#render?" do
    it "renders when a social setting is present" do
      Setting["twitter_handle"] = "my_twitter_handle"
      Setting["facebook_handle"] = "my_facebook_handle"
      Setting["youtube_handle"] = "my_youtube_handle"
      Setting["telegram_handle"] = "my_telegram_handle"
      Setting["instagram_handle"] = "my_instagram_handle"
      Setting["org_name"] = "CONSUL"

      render_inline Layout::SocialComponent.new

      expect(page).to have_css "ul"
      expect(page).to have_link "CONSUL Twitter", href: "https://twitter.com/my_twitter_handle"
      expect(page).to have_link "CONSUL Facebook", href: "https://www.facebook.com/my_facebook_handle"
      expect(page).to have_link "CONSUL YouTube", href: "https://www.youtube.com/my_youtube_handle"
      expect(page).to have_link "CONSUL Telegram", href: "https://www.telegram.me/my_telegram_handle"
      expect(page).to have_link "CONSUL Instagram", href: "https://www.instagram.com/my_instagram_handle"
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
