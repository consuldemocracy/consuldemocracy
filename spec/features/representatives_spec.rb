require 'rails_helper'

feature 'Representatives' do

  scenario "Select a representative" do
    Setting["feature.spending_proposal_features.final_voting_allowed"] = true

    forum1 = create(:forum)
    user = create(:user, :level_two)
    login_as(user)

    visit forums_path

    click_link forum1.name
    click_button "Delegate on #{forum1.name}"

    expect(page).to have_content "You have updated your representative"
    expect(page).to have_content "You are delegating your votes on #{forum1.name}"
    expect(page).to have_css("#forum_#{forum1.id}.active")
  end

  scenario "Delete a representative" do
    Setting["feature.spending_proposal_features.final_voting_allowed"] = true

    forum = create(:forum)
    user = create(:user, :level_two, representative_id: forum.id)

    login_as(user)
    visit forums_path

    expect(page).to have_content "You are delegating your votes on #{forum.name}"

    click_link "Deactivate"

    expect(page).to have_content "You do not have a representative anymore."
    expect(page).to have_content "You are not delegating your votes"
  end

  scenario "User not logged in" do
    forum = create(:forum)

    visit forums_path
    click_link forum.name

    expect(page).not_to have_selector(:button, "Delegate on #{forum.name}")
    expect(page).to have_content "Sign in to delegate"
  end

  scenario "User not verified" do
    Setting["feature.spending_proposal_features.final_voting_allowed"] = true

    unverified_user = create(:user)
    forum = create(:forum)

    login_as(unverified_user)
    visit forums_path
    click_link forum.name

    expect(page).not_to have_selector(:button, "Delegate on #{forum.name}")
    expect(page).to have_content "Verify your account to delegate"
  end

  feature "Final voting is not set" do

    let!(:user) { create(:user, :level_two) }
    let!(:forum) { create(:forum) }

    background do
      Setting['feature.spending_proposal_features.final_voting_allowed'] = false
      login_as(user)
    end

    scenario "Button is not shown" do
      visit forums_path
      click_link forum.name
      expect(page).not_to have_button("Delegate on #{forum.name}")
    end

    scenario "Forcing the creation returns forbidden", :page_driver do
      page.driver.post representatives_path(id: forum.id)
      expect(page.status_code).to eq(403)
    end

    scenario "Forcing the deletion returns forbidden", :page_driver do
      page.driver.delete representative_path(id: forum.id)
      expect(page.status_code).to eq(403)
    end

  end
end
