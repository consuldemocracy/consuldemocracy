require "rails_helper"

describe "Budget Groups" do
  let(:budget) { create(:budget, slug: "budget_slug") }
  let!(:group) { create(:budget_group, slug: "group_slug", budget: budget) }

  context "Index" do
    scenario "Render headings" do
      create(:budget_heading, group: group, name: "New heading name")

      visit budget_groups_path(budget)

      expect(page).to have_content "Select a heading"
      expect(page).to have_link "New heading name €1,000,000"
      expect(page).to have_link "Go back", href: budget_path(budget)
    end
  end
end
