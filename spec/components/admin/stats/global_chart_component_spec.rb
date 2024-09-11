require "rails_helper"

describe Admin::Stats::GlobalChartComponent do
  before do
    allow(Ahoy::Chart).to receive(:active_event_names).and_return(
      %i[budget_investment_created level_3_user]
    )
  end

  it "renders an <h2> tag with a graph and links" do
    render_inline Admin::Stats::GlobalChartComponent.new

    expect(page).to have_css "h2", exact_text: "Graphs"
    expect(page).to have_css "[data-graph]"
    expect(page).to have_link "Budget investments created"
    expect(page).to have_link "Level 3 users verified"
  end
end
