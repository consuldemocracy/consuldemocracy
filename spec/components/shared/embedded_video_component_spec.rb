require "rails_helper"

describe Shared::EmbeddedVideoComponent do
  describe "src attribute" do
    before do
      dummy_class = Class.new do
        include ActiveModel::Model

        attr_accessor :title, :video_url

        include Videoable
      end

      stub_const("DummyClass", dummy_class)
    end

    let(:record) { DummyClass.new(title: "Dummy Video", video_url: "") }
    let(:component) { Shared::EmbeddedVideoComponent.new(record) }

    it "does not render anything for empty URls" do
      render_inline component

      expect(page).not_to be_rendered
    end

    it "embeds a youtube video for youtube URLs" do
      allow(record).to receive(:video_url).and_return "http://www.youtube.com/watch?v=a7UFm6ErMPU"
      embed_url = "https://www.youtube-nocookie.com/embed/a7UFm6ErMPU"

      render_inline component

      expect(page).to have_css "[data-video-code*='src=\"#{embed_url}\"']"
    end

    it "embeds a vimeo video for vimeo URLs" do
      allow(record).to receive(:video_url).and_return "https://vimeo.com/7232823"
      embed_url = "https://player.vimeo.com/video/7232823?dnt=1"

      render_inline component

      expect(page).to have_css "[data-video-code*='src=\"#{embed_url}\"']"
    end
  end
end
