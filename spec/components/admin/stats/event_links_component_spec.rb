require "rails_helper"

describe Admin::Stats::EventLinksComponent do
  it "renders an <h2> heading followed by a list of links" do
    render_inline Admin::Stats::EventLinksComponent.new(
      %w[legislation_annotation_created legislation_answer_created]
    )

    expect(page).to have_css "h2", exact_text: "Graphs"
    expect(page).to have_link count: 2

    page.find("ul") do |list|
      expect(list).to have_link "legislation_annotation_created"
      expect(list).to have_link "legislation_answer_created"
    end
  end
end
