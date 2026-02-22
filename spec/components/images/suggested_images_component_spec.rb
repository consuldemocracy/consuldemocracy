require "rails_helper"

describe Images::SuggestedImagesComponent do
  let(:title) { "Test" }
  let(:description) { "Test description" }
  let(:component) do
    Images::SuggestedImagesComponent.new(title, description)
  end
  let(:llm_response) { instance_double(ImageSuggestions::Llm::Client::Response, results: results, errors: []) }
  let(:results) { instance_double(::Pexels::PhotoSet, photos: [photo1, photo2]) }
  let(:photo1) { instance_double(::Pexels::Photo, id: "1", src: { "small" => "https://example.com/image1.jpg" }, user: user1) }
  let(:photo2) { instance_double(::Pexels::Photo, id: "2", src: { "small" => "https://example.com/image2.jpg" }, user: user2) }
  let(:user1) { instance_double(::Pexels::User, name: "Photographer 1") }
  let(:user2) { instance_double(::Pexels::User, name: "Photographer 2") }

  before do
    allow(ImageSuggestions::Llm::Client).to receive(:call).and_return(llm_response)
  end

  describe "#suggested_images" do
    it "returns photos from results" do
      expect(component.suggested_images).to eq([photo1, photo2])
    end

    it "calls LLM client with title and description" do
      expect(ImageSuggestions::Llm::Client).to receive(:call).with(
        title: title,
        description: description
      ).and_return(llm_response)

      component.suggested_images
    end
  end

  describe "#has_errors?" do
    context "when response has no errors" do
      it "returns false" do
        expect(component.has_errors?).to be false
      end
    end

    context "when response has errors" do
      let(:llm_response) do
        instance_double(ImageSuggestions::Llm::Client::Response, results: [], errors: ["Error message"])
      end

      it "returns true" do
        expect(component.has_errors?).to be true
      end
    end
  end

  describe "#error_messages" do
    context "when response has errors" do
      let(:llm_response) do
        instance_double(ImageSuggestions::Llm::Client::Response, results: [], errors: ["Error 1", "Error 2"])
      end

      it "returns the errors array" do
        expect(component.error_messages).to eq(["Error 1", "Error 2"])
      end
    end

    context "when response has no errors" do
      it "returns empty array" do
        expect(component.error_messages).to eq([])
      end
    end
  end

  describe "rendering" do
    before { sign_in(create(:user)) }

    context "when there are errors" do
      let(:llm_response) do
        instance_double(ImageSuggestions::Llm::Client::Response, results: [], errors: ["Test error"])
      end

      it "renders error message" do
        render_inline component

        expect(page).to have_content("Test error")
        expect(page).to have_css("small.error")
      end
    end

    context "when there are suggested images" do
      it "renders suggested images" do
        render_inline component

        expect(page).to have_css(".js-attach-suggested-image", count: 2)
        expect(page).to have_css("#suggested-image-1")
        expect(page).to have_css("#suggested-image-2")
      end

      it "includes accessibility attributes" do
        render_inline component

        expect(page).to have_css('[aria-label*="Attach suggested image"]')
        expect(page).to have_css("[aria-describedby]")
      end

      it "uses pointer cursor class on attach buttons" do
        render_inline component

        expect(page).to have_css(".suggested-image-button")
      end
    end
  end
end
