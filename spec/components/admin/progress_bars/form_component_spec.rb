require "rails_helper"

describe Admin::ProgressBars::FormComponent do
  let(:progress_bar) { build(:progress_bar) }
  let(:component) { Admin::ProgressBars::FormComponent.new(progress_bar) }

  describe "percentage fields" do
    it "renders two inputs sharing the same label" do
      render_inline component

      page.find(".percentage-inputs") do |percentage_inputs|
        expect(percentage_inputs).to have_css "input:not([type=submit])", count: 2
        expect(percentage_inputs).to have_css "label", count: 1

        expect(percentage_inputs).to have_css "label#percentage_label[for=progress_bar_percentage]"
        expect(percentage_inputs.all("input")[0][:"aria-labelledby"]).to eq "percentage_label"
        expect(percentage_inputs.all("input")[0][:id]).not_to eq "percentage_input"
        expect(percentage_inputs.all("input")[1][:id]).to eq "progress_bar_percentage"
      end
    end
  end
end
