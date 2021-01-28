require "rails_helper"

describe SDG::Goals::IndexComponent, type: :component do
  let!(:goals) { SDG::Goal.all }
  let!(:phases) { SDG::Phase.all }
  let!(:component) { SDG::Goals::IndexComponent.new(goals, phases) }

  before do
    Setting["feature.sdg"] = true
  end

  it "renders a heading" do
    render_inline component

    expect(page).to have_css "h1", exact_text: "Sustainable Development Goals"
  end

  it "renders phases" do
    render_inline component

    expect(page).to have_content "Sensitization"
    expect(page).to have_content "Planning"
    expect(page).to have_content "Monitoring"
  end
end
