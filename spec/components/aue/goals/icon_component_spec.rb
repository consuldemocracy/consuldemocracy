require "rails_helper"

describe AUE::Goals::IconComponent do
  describe "#image_path" do
    let(:component) { AUE::Goals::IconComponent.new(AUE::Goal[8]) }

    it "returns icons in SVG" do
      expect(component.image_path).to eq "aue/goal_8.svg"
    end

    context "when it isn't available in SVG" do
      it "returns nil" do
        expect(component).to receive(:svg_available?).and_return(false)
        expect(component.image_path).to eq nil
      end
    end
  end
end
