require "spec_helper"

shared_examples_for "videoable" do |factory_name|
  let(:record) { build(factory_name) }

  describe "video URL validation" do
    it "is not valid when URL is not from Youtube or Vimeo" do
      record.video_url = "https://twitter.com"

      expect(record).not_to be_valid
    end

    it "is valid when URL is from Youtube or Vimeo" do
      record.video_url = "https://vimeo.com/112681885"

      expect(record).to be_valid
    end

    it "does not add errors when checking valid_video_url?" do
      record.video_url = "https://twitter.com"

      record.valid_video_url?

      expect(record.errors).to be_empty
    end

    it "is valid with an empty url" do
      record.video_url = nil

      expect(record).to be_valid
    end
  end

  describe "#embed_video_url" do
    it "returns nil when the url is nil" do
      record.video_url = nil

      expect(record.embed_video_url).to be nil
    end

    it "returns a no-cookies URL for youtube videos" do
      record.video_url = "http://www.youtube.com/watch?v=a7UFm6ErMPU"

      expect(record.embed_video_url).to eq "https://www.youtube-nocookie.com/embed/a7UFm6ErMPU"
    end

    it "returns a do not track URL for vimeo videos" do
      record.video_url = "https://vimeo.com/7232823"

      expect(record.embed_video_url).to eq "https://player.vimeo.com/video/7232823?dnt=1"
    end
  end
end
