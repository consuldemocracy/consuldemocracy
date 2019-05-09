require "rails_helper"

describe PeopleProposalsHelper do
  describe "#social_link" do
    it do
      expect(social_link("twitter", "twitter_id")).to eq("https://twitter.com/twitter_id")
    end
    it do
      expect(social_link("facebook", "facebook_id")).to eq("https://www.facebook.com/facebook_id")
    end
    it do
      expected = "https://www.instagram.com/instagram_id"
      expect(social_link("instagram", "instagram_id")).to eq(expected)
    end
    it do
      expect(social_link("youtube", "youtube_id")).to eq("https://www.youtube.com/user/youtube_id")
    end
  end

  describe "#twitter_social_link" do
    it do
      expect(twitter_social_link("twitter_id")).to eq("https://twitter.com/twitter_id")
    end
    it do
      expect(twitter_social_link("@twitter_id")).to eq("https://twitter.com/twitter_id")
    end
  end

  describe "#facebook_social_link" do
    it do
      expect(facebook_social_link("facebook_id")).to eq("https://www.facebook.com/facebook_id")
    end
    it do
      expect(facebook_social_link("@facebook_id")).to eq("https://www.facebook.com/facebook_id")
    end
  end

  describe "#instagram_social_link" do
    it do
      expect(instagram_social_link("instagram_id")).to eq("https://www.instagram.com/instagram_id")
    end
    it do
      expect(instagram_social_link("@instagram_id")).to eq("https://www.instagram.com/instagram_id")
    end
  end

  describe "#youtube_social_link" do
    it do
      expect(youtube_social_link("youtube_id")).to eq("https://www.youtube.com/user/youtube_id")
    end
  end
end
