require "rails_helper"

describe SDG::Goals::IconComponent do
  describe "#image_path" do
    let(:component) { SDG::Goals::IconComponent.new(SDG::Goal[8]) }

    it "returns icons for the first fallback language with icons" do
      allow(I18n).to receive(:fallbacks).and_return({ en: [:es, :de] })

      expect(component.image_path).to eq "sdg/es/goal_8.svg"
    end

    it "returns a PNG icon when it isn't available in SVG" do
      allow(I18n).to receive(:fallbacks).and_return({ en: [:de] })

      expect(component.image_path).to eq "sdg/de/goal_8.png"
    end

    it "returns the default icons when no fallback language has icons" do
      allow(I18n).to receive(:fallbacks).and_return({})

      expect(component.image_path).to eq "sdg/default/goal_8.svg"
    end
  end
end
