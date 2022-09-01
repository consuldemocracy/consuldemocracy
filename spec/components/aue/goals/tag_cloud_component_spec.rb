require "rails_helper"

describe AUE::Goals::TagCloudComponent do
  before do
    Setting["feature.aue"] = true
  end
  before(:each) do
    I18n.locale = :es
  end

  it "renders a title" do
    component = AUE::Goals::TagCloudComponent.new("Proposal")

    render_inline component

    expect(page).to have_content "Filtros por Agenda Urbana"
  end

  it "renders all goals ordered by code" do
    component = AUE::Goals::TagCloudComponent.new("Proposal")

    render_inline component

    expect(page).to have_selector ".aue-goal-icon", count: 10
    expect(page.first("a")[:title]).to end_with "Ver Propuestas ciudadanas del OBJETIVO 1"
    expect(page.all("a").last[:title]).to end_with "Ver Propuestas ciudadanas del OBJETIVO 10"
  end
end
