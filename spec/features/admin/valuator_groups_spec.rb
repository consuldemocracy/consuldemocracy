require 'rails_helper'

feature "Valuator groups" do

  let(:admin) { create(:administrator).user }

  background do
    login_as(admin)
  end

  scenario "Index" do
    group1 = create(:valuator_group)
    group2 = create(:valuator_group)
    3.times { create(:valuator, valuator_group: group1) }

    visit admin_valuator_groups_path

    within("#valuator_group_#{group1.id}") do
      expect(page).to have_content group1.name
      expect(page).to have_content 3
    end

    within("#valuator_group_#{group2.id}") do
      expect(page).to have_content group2.name
      expect(page).to have_content 0
    end
  end

  scenario "Show" do
    group = create(:valuator_group)
    valuator1 = create(:valuator, valuator_group: group)
    valuator2 = create(:valuator, valuator_group: group)
    valuator3 = create(:valuator, valuator_group: nil)

    visit admin_valuator_group_path(group)

    expect(page).to have_content group.name

    within("#valuators") do
      expect(page).to have_link(valuator1.email, href: admin_valuator_path(valuator1))
      expect(page).to have_link(valuator2.email, href: admin_valuator_path(valuator2))
    end
  end

  scenario "Create" do
    visit admin_valuators_path

    click_link "Valuator Groups"
    click_link "Create valuators group"

    fill_in "valuator_group_name", with: "Health"
    click_button "Create valuators group"

    expect(page).to have_content "User group created successfully"
    expect(page).to have_content "There is 1 valuator group"
    expect(page).to have_content "Health"
  end

  scenario "Update" do
    group = create(:valuator_group, name: "Health")

    visit admin_valuator_groups_path
    click_link "Edit"

    fill_in "valuator_group_name", with: "Health and Sports"
    click_button "Save valuators group"

    expect(page).to have_content "User group updated successfully"
    expect(page).to have_content "Health and Sports"
  end

  scenario "Delete" do
    group = create(:valuator_group)

    visit admin_valuator_groups_path
    click_link "Delete"

    expect(page).to have_content "User group deleted successfully"
    expect(page).to have_content "There are no valuator groups"
  end

  pending "When we change the group of a Valuator we should also change the valuator_assignments"

end