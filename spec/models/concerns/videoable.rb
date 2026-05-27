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
  end
end
