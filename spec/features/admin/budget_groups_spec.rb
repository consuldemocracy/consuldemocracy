require 'rails_helper'

feature "Admin budget groups" do

  let(:budget) { create(:budget, phase: "drafting") }

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Feature flag" do

    background do
      Setting["feature.budgets"] = nil
    end

    after do
      Setting["feature.budgets"] = true
    end

    scenario "Disabled with a feature flag" do
      expect { visit admin_budget_groups_path(budget) }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario "Displaying no groups for budget" do
      visit admin_budget_groups_path(budget)

      expect(page).to have_content "No groups created yet. Each user will be able to vote in only one heading per group."
    end

    scenario "Displaying groups" do
      group1 = create(:budget_group, budget: budget)

      group2 = create(:budget_group, budget: budget)
      create(:budget_heading, group: group2)

      group3 = create(:budget_group, budget: budget, max_votable_headings: 2)
      3.times { create(:budget_heading, group: group3) }

      visit admin_budget_groups_path(budget)
      expect(page).to have_content "There are 3 groups"

      within "#budget_group_#{group1.id}" do
        expect(page).to have_content(group1.name)
        expect(page).to have_content(group1.max_votable_headings)
        expect(page).to have_content(group1.headings.count)
        expect(page).to have_link "Manage headings", href: admin_budget_group_headings_path(budget, group1)
      end

      within "#budget_group_#{group2.id}" do
        expect(page).to have_content(group2.name)
        expect(page).to have_content(group2.max_votable_headings)
        expect(page).to have_content(group2.headings.count)
        expect(page).to have_link "Manage headings", href: admin_budget_group_headings_path(budget, group2)
      end

      within "#budget_group_#{group3.id}" do
        expect(page).to have_content(group3.name)
        expect(page).to have_content(group3.max_votable_headings)
        expect(page).to have_content(group3.headings.count)
        expect(page).to have_link "Manage headings", href: admin_budget_group_headings_path(budget, group3)
      end
    end

    scenario "Delete a group without headings" do
      group = create(:budget_group, budget: budget)

      visit admin_budget_groups_path(budget)
      within("#budget_group_#{group.id}") { click_link "Delete" }

      expect(page).to have_content "Group deleted successfully"
      expect(page).not_to have_selector "#budget_group_#{group.id}"
    end

    scenario "Try to delete a group with headings" do
      group = create(:budget_group, budget: budget)
      create(:budget_heading, group: group)

      visit admin_budget_groups_path(budget)
      within("#budget_group_#{group.id}") { click_link "Delete" }

      expect(page).to have_content "You cannot destroy a Group that has associated headings"
      expect(page).to have_selector "#budget_group_#{group.id}"
    end

  end

  context "New" do

    scenario "Create group" do
      visit admin_budget_groups_path(budget)
      click_link "Create new group"

      fill_in "Group name", with: "All City"

      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"
      expect(page).to have_link "All City"
    end

    scenario "Maximum number of headings in which a user can vote is set to 1 by default" do
      visit new_admin_budget_group_path(budget)
      fill_in "Group name", with: "All City"

      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"
      expect(Budget::Group.first.max_votable_headings).to be 1
    end

    scenario "Group name is mandatory" do
      visit new_admin_budget_group_path(budget)
      click_button "Create new group"

      expect(page).not_to have_content "Group created successfully!"
      expect(page).to have_css("label.error", text: "Group name")
      expect(page).to have_content "can't be blank"
    end

  end

  context "Edit" do

    scenario "Show group information" do
      group = create(:budget_group, budget: budget, max_votable_headings: 2)
      2.times { create(:budget_heading, group: group) }

      visit admin_budget_groups_path(budget)
      within("#budget_group_#{group.id}") { click_link "Edit" }

      expect(page).to have_field "Group name", with: group.name
      expect(page).to have_field "Maximum number of headings in which a user can vote", with: "2"
    end

  end

  context "Update" do
    let!(:group) { create(:budget_group, budget: budget, name: "All City") }

    scenario "Updates group" do
      2.times { create(:budget_heading, group: group) }

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "All City"

      fill_in "Group name", with: "Districts"
      select "2", from: "Maximum number of headings in which a user can vote"
      click_button "Edit group"

      expect(page).to have_content "Group updated successfully"

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "Districts"
      expect(page).to have_field "Maximum number of headings in which a user can vote", with: "2"
    end

    scenario "Group name is already used" do
      create(:budget_group, budget: budget, name: "Districts")

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "All City"

      fill_in "Group name", with: "Districts"
      click_button "Edit group"

      expect(page).not_to have_content "Group updated successfully"
      expect(page).to have_css("label.error", text: "Group name")
      expect(page).to have_content "has already been taken"
    end

  end
end
