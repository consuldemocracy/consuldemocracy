require "rails_helper"

describe "Hidden content search", :admin do
  scenario "finds matching records" do
    create(:budget_investment, :hidden, title: "New football field")
    create(:budget_investment, :hidden, title: "New basketball field")
    create(:budget_investment, :hidden, title: "New sports center")

    visit admin_hidden_budget_investments_path
    fill_in "search", with: "field"
    click_button "Search"

    expect(page).not_to have_content "New sports center"
    expect(page).to have_content "New football field"
    expect(page).to have_content "New basketball field"
  end

  scenario "returns no results if no records match the term" do
    create(:comment, :hidden, body: "I like this feature")

    visit admin_hidden_comments_path
    fill_in "search", with: "love"
    click_button "Search"

    expect(page).to have_content "There are no hidden comments"
    expect(page).not_to have_content "I like this feature"
    expect(page).not_to have_content "I hate this feature"
  end

  scenario "returns all records when the search term is empty" do
    create(:debate, :hidden, title: "Can we make it better?")
    create(:debate, :hidden, title: "Can we make it worse?")

    visit admin_hidden_debates_path(search: "worse")

    expect(page).not_to have_content "Can we make it better?"
    expect(page).to have_content "Can we make it worse?"

    fill_in "search", with: " "
    click_button "Search"

    expect(page).to have_content "Can we make it better?"
    expect(page).to have_content "Can we make it worse?"
    expect(page).not_to have_content "There are no hidden debates"
  end

  scenario "keeps search parameters after restoring a record" do
    create(:proposal_notification, :hidden, title: "Someone is telling you something")
    create(:proposal_notification, :hidden, title: "Someone else says whatever")
    create(:proposal_notification, :hidden, title: "Nobody is saying anything")

    visit admin_hidden_proposal_notifications_path(search: "Someone")

    expect(page).to have_content "Someone is telling you something"
    expect(page).to have_content "Someone else says whatever"
    expect(page).not_to have_content "Nobody is saying anything"

    within "tr", text: "Someone is telling you something" do
      accept_confirm("Are you sure? Restore") { click_button "Restore" }
    end

    expect(page).not_to have_content "Someone is telling you something"
    expect(page).to have_content "Someone else says whatever"
    expect(page).not_to have_content "Nobody is saying anything"
  end

  scenario "keeps search parameters after confirming moderation" do
    create(:proposal, :hidden, title: "Reduce the incoming traffic")
    create(:proposal, :hidden, title: "Reduce pollution")
    create(:proposal, :hidden, title: "Increment pollution")

    visit admin_hidden_proposals_path(search: "Reduce")

    expect(page).to have_content "Reduce the incoming traffic"
    expect(page).to have_content "Reduce pollution"
    expect(page).not_to have_content "Increment pollution"

    within("tr", text: "Reduce the incoming traffic") { click_button "Confirm moderation" }

    expect(page).not_to have_content "Reduce the incoming traffic"
    expect(page).to have_content "Reduce pollution"
    expect(page).not_to have_content "Increment pollution"
  end

  scenario "keeps search parameters while browsing through filters" do
    create(:user, :hidden, username: "person1")
    create(:user, :hidden, username: "alien1")
    create(:user, :hidden, :with_confirmed_hide, username: "person2")
    create(:user, :hidden, :with_confirmed_hide, username: "alien2")

    visit admin_hidden_users_path(search: "person")

    expect(page).to have_content "person1"
    expect(page).not_to have_content "person2"
    expect(page).not_to have_content "alien1"
    expect(page).not_to have_content "alien2"

    click_link "Confirmed"

    expect(page).not_to have_content "person1"
    expect(page).to have_content "person2"
    expect(page).not_to have_content "alien1"
    expect(page).not_to have_content "alien2"
  end

  scenario "keeps filter parameters after searching" do
    create(:user, :hidden, :with_confirmed_hide, username: "person1")
    create(:user, :hidden, :with_confirmed_hide, username: "alien1")
    create(:user, :hidden, username: "person2")
    create(:user, :hidden, username: "alien2")

    visit admin_hidden_users_path(filter: "with_confirmed_hide")

    fill_in "search", with: "alien"
    click_button "Search"

    expect(page).not_to have_content "person1"
    expect(page).to have_content "alien1"
    expect(page).not_to have_content "person2"
    expect(page).not_to have_content "alien2"

    expect(page).to have_content "Confirmed"
    expect(page).not_to have_link "Confirmed"
  end
end
