require "rails_helper"

describe Pages::Help::SectionComponent do
  describe "#image_path" do
    it "returns the image for the first fallback language with an image" do
      allow(I18n).to receive(:fallbacks).and_return({ en: [:es, :de] })

      component = Pages::Help::SectionComponent.new("proposals")

      expect(component.image_path).to eq "help/proposals_es.png"
    end

    it "returns the default image when no fallback language has an image" do
      allow(I18n).to receive(:fallbacks).and_return({})

      component = Pages::Help::SectionComponent.new("proposals")

      expect(component.image_path).to eq "help/proposals.png"
    end

    it "returns nil when there is no image" do
      component = Pages::Help::SectionComponent.new("polls")

      expect(component.image_path).to be nil
    end
  end

  describe "image tag" do
    it "renders an image on sections with an image" do
      render_inline Pages::Help::SectionComponent.new("debates")

      expect(page).to have_selector "img"
      expect(page).to have_selector "figure"
    end

    it "does not render an image tag when there is no image" do
      render_inline Pages::Help::SectionComponent.new("processes")

      expect(page).not_to have_selector "img"
      expect(page).not_to have_selector "figure"
    end
  end
end
