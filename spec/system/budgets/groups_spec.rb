require "rails_helper"

describe "Budget Groups" do
  let(:budget) { create(:budget, slug: "budget_slug") }
  let!(:group) { create(:budget_group, slug: "group_slug", budget: budget) }

  context "Load" do
    scenario "finds group using budget slug and group slug" do
      visit budget_group_path("budget_slug", "group_slug")
      expect(page).to have_content "Select a heading"
    end

    scenario "finds group using budget id and group id" do
      visit budget_group_path(budget, group)
      expect(page).to have_content "Select a heading"
    end
  end

  context "Show" do
    scenario "Headings are sorted by name" do
      last_heading = create(:budget_heading, group: group, name: "BBB")
      first_heading = create(:budget_heading, group: group, name: "AAA")

      visit budget_group_path(budget, group)

      expect(first_heading.name).to appear_before(last_heading.name)
    end

    scenario "Back link" do
      visit budget_group_path(budget, group)

      click_link "Go back"

      expect(page).to have_current_path budget_path(budget)
    end
  end

  context "Index" do
    scenario "Render headings" do
      create(:budget_heading, group: group, name: "New heading name")

      visit budget_groups_path(budget)

      expect(page).to have_content "Select a heading"
      expect(page).to have_link "New heading name"
      expect(page).to have_link "Go back", href: budget_path(budget)
    end
  end
end
