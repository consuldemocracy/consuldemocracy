require "rails_helper"

describe "Admin budget groups", :admin do
  let(:budget) { create(:budget, :drafting) }

  context "Load" do
    let!(:budget) { create(:budget, slug: "budget_slug") }
    let!(:group)  { create(:budget_group, slug: "group_slug", budget: budget) }

    scenario "finds budget and group by slug" do
      visit edit_admin_budget_group_path("budget_slug", "group_slug")
      expect(page).to have_content(budget.name)
      expect(page).to have_field "Group name", with: group.name
    end
  end

  context "List of groups from budget page" do
    scenario "Displaying no groups for budget" do
      visit admin_budget_path(budget)

      within "section", text: "Heading groups" do
        expect(page.text).to eq "Heading groups\nAdd group"
      end
    end

    scenario "Displaying groups" do
      above = create(:budget_group, budget: budget, name: "Above ground")
      below = create(:budget_group, budget: budget, name: "Below ground")

      1.times { create(:budget_heading, group: above) }
      2.times { create(:budget_heading, group: below) }

      visit admin_budget_path(budget)

      within "section", text: "Heading groups" do
        within "section", text: "Above ground" do
          expect(page).to have_css "h4", exact_text: "Above ground"
          expect(page).not_to have_content "Maximum number of headings"
        end

        within "section", text: "Below ground" do
          expect(page).to have_css "h4", exact_text: "Below ground"
          expect(page).to have_content "Maximum number of headings in which a user can select projects 1"
        end
      end
    end

    scenario "Delete a group without headings" do
      create(:budget_group, budget: budget, name: "Nowhere")

      visit admin_budget_path(budget)

      accept_confirm("Are you sure? This action will delete \"Nowhere\" and can't be undone.") do
        click_button "Delete Nowhere"
      end

      expect(page).to have_content "Group deleted successfully"
      expect(page).not_to have_content "Nowhere"
    end

    scenario "Try to delete a group with headings" do
      group = create(:budget_group, budget: budget, name: "Everywhere")
      create(:budget_heading, group: group, name: "Everything")

      visit admin_budget_path(budget)

      accept_confirm("Are you sure? This action will delete \"Everywhere\" and can't be undone.") do
        click_button "Delete Everywhere"
      end
      expect(page).to have_content "You cannot delete a Group that has associated headings"
      expect(page).to have_content "Everywhere"
    end
  end

  context "New" do
    scenario "Create group" do
      visit admin_budget_path(budget)
      click_link "Add group"

      fill_in "Group name", with: "All City"

      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"

      within "section", text: "Heading groups" do
        expect(page).to have_css "h4", exact_text: "All City"
      end
    end

    scenario "Group name is mandatory" do
      visit new_admin_budget_group_path(budget)
      click_button "Create new group"

      expect(page).not_to have_content "Group created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Group name")
      expect(page).to have_content "can't be blank"
    end
  end

  context "Edit" do
    scenario "Show group information" do
      group = create(:budget_group, budget: budget, name: "Everywhere", max_votable_headings: 2)
      2.times { create(:budget_heading, group: group) }

      visit admin_budget_path(budget)

      click_link "Edit Everywhere"

      expect(page).to have_field "Group name", with: "Everywhere"
      expect(page).to have_field "Maximum number of headings in which a user can select projects", with: "2"
    end

    describe "Select for maximum number of headings to select projects" do
      scenario "is present if there are several headings in the group" do
        group = create(:budget_group, budget: budget)
        2.times { create(:budget_heading, group: group) }

        visit edit_admin_budget_group_path(budget, group)

        expect(page).to have_field "Maximum number of headings in which a user can select projects"
      end

      scenario "is not present if there's only one heading in the group" do
        group = create(:budget_group, budget: budget)
        create(:budget_heading, group: group)

        visit edit_admin_budget_group_path(budget, group)

        expect(page).not_to have_field "Maximum number of headings in which a user can select projects"
      end

      scenario "is not present if there are no headings in the group" do
        group = create(:budget_group, budget: budget)

        visit edit_admin_budget_group_path(budget, group)

        expect(page).not_to have_field "Maximum number of headings in which a user can select projects"
      end
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      group = create(:budget_group, budget: budget, name: "Old English Name")

      visit edit_admin_budget_group_path(budget, group)

      select "Español", from: :add_language
      fill_in "Group name", with: "Spanish name"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit budget_group_path(budget, id: "old-english-name")

      expect(page).to have_content "Select a heading"

      visit edit_admin_budget_group_path(budget, group)

      select "English", from: :select_language
      fill_in "Group name", with: "New English Name"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit budget_group_path(budget, id: "new-english-name")

      expect(page).to have_content "Select a heading"
    end
  end

  context "Update" do
    let!(:group) { create(:budget_group, budget: budget, name: "All City") }

    scenario "Updates group" do
      2.times { create(:budget_heading, group: group) }

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "All City"

      fill_in "Group name", with: "Districts"
      select "2", from: "Maximum number of headings in which a user can select projects"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "Districts"
      expect(page).to have_field "Maximum number of headings in which a user can select projects", with: "2"
    end

    scenario "Group name is already used" do
      create(:budget_group, budget: budget, name: "Districts")

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "All City"

      fill_in "Group name", with: "Districts"
      click_button "Save group"

      expect(page).not_to have_content "Group updated successfully"
      expect(page).to have_css(".is-invalid-label", text: "Group name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
    end
  end
end
