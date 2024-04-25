require "rails_helper"

describe Admin::Stats::ChartComponent do
  it "renders a tag with JSON data" do
    create(:user, :level_three, verified_at: "2009-09-09")
    chart = Ahoy::Chart.new(:level_3_user)

    render_inline Admin::Stats::ChartComponent.new(chart)

    expect(page).to have_css "h2", exact_text: "Level 3 users verified (1)"
    expect(page).to have_css "[data-graph='{\"x\":[\"2009-09-09\"],\"Level 3 users verified\":[1]}']"
  end
end
