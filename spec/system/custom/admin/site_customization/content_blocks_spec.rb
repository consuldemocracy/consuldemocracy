require "rails_helper"

describe "Admin custom content blocks", :admin do
  context "Delete" do
    scenario "Remove heading content block if heading is deleted" do
      budget = create(:budget)
      heading = create(:budget_heading, budget: budget, price: 1000, allow_custom_content: true)

      expect(Budget::Heading.count).to eq 1

      visit admin_site_customization_content_blocks_path

      click_link "Create new content block"

      select heading.name, from: "Name"
      select "en", from: "locale"
      fill_in "Body", with: "Block content for heading"

      click_button "Create Custom content block"

      expect(page).to have_content("#{heading.name} (en)")
      expect(page).to have_content("Block content for heading")

      expect(Budget::ContentBlock.count).to eq 1

      visit admin_budget_path(budget)

      within "#budget_heading_#{heading.id}" do
        accept_confirm { click_button "Delete" }
      end

      visit admin_site_customization_content_blocks_path

      expect(page).not_to have_content("#{heading.name} (en)")
      expect(page).not_to have_content("Block content for heading")

      expect(Budget::Heading.count).to eq 0
      expect(Budget::ContentBlock.count).to eq 0
    end
  end
end
