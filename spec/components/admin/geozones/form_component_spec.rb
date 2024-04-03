require "rails_helper"

describe Admin::Geozones::FormComponent do
  let(:geozone) { build(:geozone) }
  let(:component) { Admin::Geozones::FormComponent.new(geozone) }

  describe "color fields" do
    it "renders two inputs sharing the same label" do
      render_inline component

      page.find(".color-inputs") do |color_inputs|
        expect(color_inputs).to have_css "input", count: 2
        expect(color_inputs).to have_css "label", count: 1

        expect(color_inputs).to have_css "label#color_label[for=color_input]"
        expect(color_inputs.all("input")[0][:"aria-labelledby"]).to eq "color_label"
        expect(color_inputs.all("input")[0][:id]).not_to eq "color_input"
        expect(color_inputs.all("input")[1][:id]).to eq "color_input"
      end
    end
  end
end
