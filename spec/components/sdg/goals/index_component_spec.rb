require "rails_helper"

describe SDG::Goals::IndexComponent do
  let!(:goals) { SDG::Goal.all }
  let!(:phases) { SDG::Phase.all }
  let!(:component) { SDG::Goals::IndexComponent.new(goals, header: nil, phases: phases) }

  before do
    Setting["feature.sdg"] = true
  end

  describe "header" do
    it "renders the default header when a custom one is not defined" do
      render_inline component

      expect(page).to have_css "h1", exact_text: "Sustainable Development Goals"
    end

    it "renders a custom header" do
      sdg_web_section = WebSection.find_by!(name: "sdg")
      header = create(:widget_card, cardable: sdg_web_section)
      component = SDG::Goals::IndexComponent.new(goals, header: header, phases: phases)

      render_inline component

      expect(page).to have_content header.title
      expect(page).not_to have_css "h1", exact_text: "Sustainable Development Goals"
    end
  end

  it "renders phases" do
    render_inline component

    expect(page).to have_content "Sensitization"
    expect(page).to have_content "Planning"
    expect(page).to have_content "Monitoring"
  end
end
