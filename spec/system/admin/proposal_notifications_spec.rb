require "rails_helper"

describe "Admin proposal notifications", :admin do
  scenario "List shows all relevant info" do
    proposal_notification = create(:proposal_notification, :hidden)
    visit admin_hidden_proposal_notifications_path

    expect(page).to have_content(proposal_notification.title)
    expect(page).to have_content(proposal_notification.body)
  end

  scenario "Restore" do
    proposal_notification = create(:proposal_notification, :hidden, created_at: Date.current - 5.days)
    visit admin_hidden_proposal_notifications_path

    click_link "Restore"

    expect(page).not_to have_content(proposal_notification.title)

    expect(proposal_notification.reload).not_to be_hidden
    expect(proposal_notification).to be_ignored
    expect(proposal_notification).not_to be_moderated
  end

  scenario "Confirm hide" do
    proposal_notification = create(:proposal_notification, :hidden, created_at: Date.current - 5.days)
    visit admin_hidden_proposal_notifications_path

    click_link "Confirm moderation"

    expect(page).not_to have_content(proposal_notification.title)
    click_link("Confirmed")
    expect(page).to have_content(proposal_notification.title)

    expect(proposal_notification.reload).to be_confirmed_hide
  end

  scenario "Current filter is properly highlighted" do
    visit admin_hidden_proposal_notifications_path
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposal_notifications_path(filter: "Pending")
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposal_notifications_path(filter: "all")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposal_notifications_path(filter: "with_confirmed_hide")
    expect(page).to have_link("All")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("Confirmed")
  end

  scenario "Filtering proposals" do
    create(:proposal_notification, :hidden, title: "Unconfirmed notification")
    create(:proposal_notification, :hidden, :with_confirmed_hide, title: "Confirmed notification")

    visit admin_hidden_proposal_notifications_path(filter: "pending")
    expect(page).to have_content("Unconfirmed notification")
    expect(page).not_to have_content("Confirmed notification")

    visit admin_hidden_proposal_notifications_path(filter: "all")
    expect(page).to have_content("Unconfirmed notification")
    expect(page).to have_content("Confirmed notification")

    visit admin_hidden_proposal_notifications_path(filter: "with_confirmed_hide")
    expect(page).not_to have_content("Unconfirmed notification")
    expect(page).to have_content("Confirmed notification")
  end

  scenario "Action links remember the pagination setting and the filter" do
    allow(ProposalNotification).to receive(:default_per_page).and_return(2)
    4.times { create(:proposal_notification, :hidden, :with_confirmed_hide) }

    visit admin_hidden_proposal_notifications_path(filter: "with_confirmed_hide", page: 2)

    click_on("Restore", match: :first, exact: true)

    expect(current_url).to include("filter=with_confirmed_hide")
    expect(current_url).to include("page=2")
  end
end
