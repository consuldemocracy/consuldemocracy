require "rails_helper"

describe Admin::Legislation::Processes::FormComponent, :admin do
  let(:process) { build(:legislation_process) }
  let(:component) { Admin::Legislation::Processes::FormComponent.new(process) }

  describe "background color fields" do
    it "renders two inputs sharing the same label" do
      render_inline component

      page.find(".background-color-inputs") do |color_inputs|
        expect(color_inputs).to have_css "input", count: 2
        expect(color_inputs).to have_css "label", count: 1

        expect(color_inputs).to have_css "label#background_color_label[for=background_color_input]"
        expect(color_inputs.all("input")[0][:"aria-labelledby"]).to eq "background_color_label"
        expect(color_inputs.all("input")[0][:id]).not_to eq "background_color_input"
        expect(color_inputs.all("input")[1][:id]).to eq "background_color_input"
      end
    end
  end

  describe "font color fields" do
    it "renders two inputs sharing the same label" do
      render_inline component

      page.find(".font-color-inputs") do |color_inputs|
        expect(color_inputs).to have_css "input", count: 2
        expect(color_inputs).to have_css "label", count: 1

        expect(color_inputs).to have_css "label#font_color_label[for=font_color_input]"
        expect(color_inputs.all("input")[0][:"aria-labelledby"]).to eq "font_color_label"
        expect(color_inputs.all("input")[0][:id]).not_to eq "font_color_input"
        expect(color_inputs.all("input")[1][:id]).to eq "font_color_input"
      end
    end
  end
end
