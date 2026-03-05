require "rails_helper"

describe Images::SuggestedImagesComponent do
  let(:title) { "Test" }
  let(:description) { "Test description" }
  let(:component) { Images::SuggestedImagesComponent.new(title, description) }
  let(:llm_response) { instance_double(ImageSuggestions::Llm::Client::Response, results: results, errors: []) }
  let(:results) { instance_double(::Pexels::PhotoSet, photos: [photo]) }
  let(:photo) { instance_double(::Pexels::Photo, id: "1", src: { "small" => "https://example.com/image1.jpg" }, user: user) }
  let(:user) { instance_double(::Pexels::User, name: "Photographer 1") }

  before { allow(ImageSuggestions::Llm::Client).to receive(:call).and_return(llm_response) }

  describe "#suggested_images" do
    it "returns photos from results" do
      expect(component.suggested_images).to eq [photo]
    end

    it "calls LLM client with title and description" do
      expect(ImageSuggestions::Llm::Client).to receive(:call).with(
        title: title,
        description: description
      ).and_return(llm_response)

      component.suggested_images
    end

    context "when title and description are both blank" do
      let(:title) { "" }
      let(:description) { "" }

      it "returns an empty array without calling the LLM client" do
        expect(ImageSuggestions::Llm::Client).not_to receive(:call)

        expect(component.suggested_images).to eq []
      end
    end

    context "when response results are blank" do
      let(:llm_response) do
        instance_double(ImageSuggestions::Llm::Client::Response, results: nil, errors: [])
      end

      it "returns an empty array" do
        expect(component.suggested_images).to eq []
      end
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
        expect(component.error_messages).to eq ["Error 1", "Error 2"]
      end
    end

    context "when response has no errors" do
      it "returns empty array" do
        expect(component.error_messages).to eq []
      end
    end
  end

  describe "rendering" do
    it "calls the LLM client only once when the view is rendered" do
      expect(ImageSuggestions::Llm::Client).to receive(:call).once.and_return(llm_response)

      render_inline component

      expect(page).to have_css ".js-attach-suggested-image", count: 1
    end

    context "when there are no results and no errors" do
      let(:llm_response) { instance_double(ImageSuggestions::Llm::Client::Response, results: [], errors: []) }

      it "shows the suggest button and the no images found message" do
        render_inline component

        expect(page).to have_content "Suggest an image with AI"
        expect(page).to have_content "No suggestions could be found."
      end
    end

    context "when there are errors" do
      let(:llm_response) do
        instance_double(ImageSuggestions::Llm::Client::Response, results: [], errors: ["Test error"])
      end

      it "renders error message" do
        render_inline component

        expect(page).to have_content "Test error"
        expect(page).to have_css "small.error"
      end
    end

    context "when there are suggested images" do
      it "renders the grid with attach buttons" do
        render_inline component

        expect(page).to have_css ".js-attach-suggested-image", count: 1
        expect(page).to have_css "#suggested-image-1"
        expect(page).to have_css ".suggested-image-button"
      end

      it "includes accessibility attributes for container, buttons and images" do
        render_inline component

        expect(page).to have_css ".suggested-images-container[role='region'][aria-label='Suggested images']"
        expect(page).to have_css ".js-attach-suggested-image[aria-label='Attach suggested image 1 of 1']"
        expect(page).to have_css "img.suggested-image[alt='Photographer 1']"
        expect(page).to have_css "[aria-describedby='suggested-image-desc-1']"
        expect(page).to have_css "#suggested-image-desc-1"
      end
    end
  end
end
