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
  end
end
