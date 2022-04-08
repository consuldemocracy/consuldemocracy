require "rails_helper"

describe "Moderate users" do
  scenario "Hide" do
    citizen = create(:user)
    moderator = create(:moderator)

    debate1 = create(:debate, author: citizen)
    debate2 = create(:debate, author: citizen)
    debate3 = create(:debate)
    comment3 = create(:comment, user: citizen, commentable: debate3, body: "SPAMMER")

    login_as(moderator.user)
    visit debates_path

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).to have_content(comment3.body)

    visit debate_path(debate1)

    within("#debate_#{debate1.id}") do
      accept_confirm { click_link "Hide author" }
    end

    expect(page).to have_current_path(debates_path)
    expect(page).not_to have_content(debate1.title)
    expect(page).not_to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).not_to have_content(comment3.body)

    click_link("Sign out")

    visit root_path

    click_link "Sign in"
    fill_in "user_login",    with: citizen.email
    fill_in "user_password", with: citizen.password
    click_button "Enter"

    expect(page).to have_content "Invalid Email or username or password"
    expect(page).to have_current_path(new_user_session_path)
  end

  scenario "Search and ban users" do
    citizen = create(:user, username: "Wanda Maximoff")
    moderator = create(:moderator)

    login_as(moderator.user)

    visit moderation_users_path

    expect(page).not_to have_content citizen.name
    fill_in "search", with: "Wanda"
    click_button "Search"

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).not_to have_content "Blocked"
      click_link "Block"
    end

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).to have_content "Blocked"
    end
  end

  scenario "Hiding a user removes all roles" do
    moderator = create(:moderator)
    admin = create(:administrator)
    valuator = create(:valuator)
    manager = create(:manager)
    sdg_manager = create(:sdg_manager)
    all_roles = create(:user)
    create(:administrator, user: all_roles)
    create(:valuator, user: all_roles)
    create(:moderator, user: all_roles)
    create(:manager, user: all_roles)
    create(:sdg_manager, user: all_roles)

    debate1 = create(:debate, author: admin.user)
    debate2 = create(:debate, author: valuator.user)
    debate3 = create(:debate, author: manager.user)
    debate4 = create(:debate, author: sdg_manager.user)
    debate5 = create(:debate, author: all_roles)

    expect(Administrator.count).to eq 2
    expect(Valuator.count).to eq 2
    expect(Manager.count).to eq 2
    expect(SDG::Manager.count).to eq 2
    expect(Moderator.count).to eq 2

    login_as(moderator.user)

    [debate1, debate2, debate3, debate4, debate5].each do |debate|
      visit debate_path(debate)

      within("#debate_#{debate.id}") do
        accept_confirm { click_link "Hide author" }
      end

      expect(page).to have_current_path(debates_path)
    end

    expect(Administrator.count).to eq 0
    expect(Valuator.count).to eq 0
    expect(Manager.count).to eq 0
    expect(SDG::Manager.count).to eq 0
    expect(Moderator.count).to eq 1
  end
end
