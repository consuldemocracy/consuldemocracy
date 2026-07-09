require "rails_helper"

describe ImageSuggestions::SuggestionsComponent do
  let(:user) { double(name: "Photographer 1") }
  let(:photo) { double(id: "1", src: { "small" => "https://example.com/image1.jpg" }, user: user) }
  let(:results) { double(photos: [photo]) }
  let(:llm_response) { double(results: results, errors: []) }
  let(:component) { ImageSuggestions::SuggestionsComponent.new(llm_response) }

  context "when there are no results and no errors" do
    let(:llm_response) { double(results: [], errors: []) }

    it "shows the suggest button and the no images found message" do
      render_inline component

      expect(page).to have_content "Suggest an image with AI"
      expect(page).to have_content "No suggestions could be found."
      expect(page).not_to have_css "img"
    end
  end

  context "when there are errors" do
    let(:llm_response) { double(results: [], errors: ["Test error"]) }

    it "shows the suggest button and the no images found message" do
      render_inline component

      expect(page).to have_content "Suggest an image with AI"
      expect(page).to have_content "No suggestions could be found."
      expect(page).not_to have_css "img"
    end

    it "renders error message" do
      render_inline component

      expect(page).to have_content "Test error"
      expect(page).to have_css "[role=alert] .error"
    end
  end

  context "when there are suggested images" do
    it "renders the grid with attach buttons" do
      render_inline component

      expect(page).to have_css ".suggested-image-button", count: 1
      expect(page).to have_css "img", count: 1
      expect(page).to have_css "img[src='https://example.com/image1.jpg']"
    end

    it "includes accessibility attributes for container, buttons and images" do
      render_inline component

      expect(page).to have_button "Attach suggested image 1 of 1"
      expect(page).to have_css ".suggested-images-container[role='region'][aria-label='Suggested images']"
      expect(page).to have_css ".suggested-images img[alt='Photographer 1']"
    end
  end
end
