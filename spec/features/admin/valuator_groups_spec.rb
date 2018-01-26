require 'rails_helper'

feature "Valuator groups", :focus do

  let(:admin) { create(:administrator).user }

  background do
    login_as(admin)
  end

  scenario "Index" do
    group1 = create(:valuator_group)
    group2 = create(:valuator_group)

    visit admin_valuator_groups_path

    expect(page).to have_content group1.name
    expect(page).to have_content group2.name
  end

  scenario "Show" do
    group = create(:valuator_group)

    visit admin_valuator_group_path(group)

    expect(page).to have_content group.name
  end

  scenario "Create" do
    visit admin_valuators_path

    click_link "Grupos de evaluadores"
    click_link "Nuevo"

    fill_in "valuator_group_name", with: "Health"
    click_button "Create Valuator group"

    expect(page).to have_content "User group created successfully"
    #expect(page).to have_content "There are 1 groups of valuators"
    expect(page).to have_content "Health"
  end

  scenario "Update" do
    group = create(:valuator_group, name: "Health")

    visit admin_valuator_groups_path
    click_link "Edit"

    fill_in "valuator_group_name", with: "Health and Sports"
    click_button "Update Valuator group"

    expect(page).to have_content "User group updated successfully"
    expect(page).to have_content "Health and Sports"
  end

  scenario "Destroy" do
    group = create(:valuator_group)

    visit admin_valuator_groups_path
    click_link "Destroy"

    expect(page).to have_content "User group destroyed successfully"
    expect(page).to have_content "There are 0 groups of users"
  end

end