class Layout::SocialComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  private

    def sites
      {
        twitter: "https://twitter.com",
        facebook: "https://www.facebook.com",
        youtube: "https://www.youtube.com",
        telegram: "https://www.telegram.me",
        instragram: "https://www.instagram.com"
      }
    end
end
