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
      accept_confirm("Are you sure? This will hide the user \"#{debate1.author.name}\" and all their contents.") do
        click_button "Block author"
      end
    end

    expect(page).to have_current_path(debates_path)
    expect(page).not_to have_content(debate1.title)
    expect(page).not_to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).not_to have_content(comment3.body)

    click_link "Sign out"

    expect(page).to have_content "You have been signed out successfully"

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

      accept_confirm { click_button "Block" }
    end

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).to have_content "Blocked"
    end
  end

  scenario "Hide users in the moderation section" do
    create(:user, username: "Rick")

    login_as(create(:moderator).user)
    visit moderation_users_path(search: "Rick")

    within("#moderation_users") do
      accept_confirm('This will hide the user "Rick" without hiding their contents') do
        click_button "Hide"
      end
    end

    expect(page).to have_content "The user has been hidden"

    within("#moderation_users") do
      expect(page).to have_content "Hidden"
    end
  end

  scenario "Block a user removes all their roles" do
    admin = create(:administrator).user
    user = create(:user, username: "Budget administrator")
    budget = create(:budget, administrators: [create(:administrator, user: user)])
    debate = create(:debate, author: user)
    login_as(admin)
    visit admin_budget_budget_investments_path(budget)

    expect(page).to have_select options: ["All administrators", "Budget administrator"]

    visit debate_path(debate)
    within("#debate_#{debate.id}") do
      accept_confirm { click_button "Block author" }
    end

    expect(page).to have_current_path(debates_path)

    visit admin_budget_budget_investments_path(budget)

    expect(page).to have_select options: ["All administrators"]
  end
end
