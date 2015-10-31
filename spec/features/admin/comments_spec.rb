require 'rails_helper'

feature 'Admin comments' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Do not show comments from blocked users" do
    comment = create(:comment, :hidden, body: "SPAM from SPAMMER")
    proposal = create(:proposal, author: comment.author)
    create(:comment, commentable: proposal, user: comment.author, body: "Good Proposal!")

    visit admin_comments_path
    expect(page).to have_content("SPAM from SPAMMER")
    expect(page).not_to have_content("Good Proposal!")

    visit proposal_path(proposal)
    within("#proposal_#{proposal.id}") do
      click_link 'Hide author'
    end

    visit admin_comments_path
    expect(page).to_not have_content("SPAM from SPAMMER")
    expect(page).not_to have_content("Good Proposal!")
  end

  scenario "Restore" do
    comment = create(:comment, :hidden, body: 'Not really SPAM')
    visit admin_comments_path

    click_link 'Restore'

    expect(page).to_not have_content(comment.body)

    expect(comment.reload).to_not be_hidden
    expect(comment).to be_ignored_flag
  end

  scenario "Confirm hide" do
    comment = create(:comment, :hidden, body: 'SPAM')
    visit admin_comments_path

    click_link 'Confirm'

    expect(page).to_not have_content(comment.body)
    click_link('Confirmed')
    expect(page).to have_content(comment.body)

    expect(comment.reload).to be_confirmed_hide
  end

  scenario "Current filter is properly highlighted" do
    visit admin_comments_path
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_comments_path(filter: 'Pending')
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_comments_path(filter: 'all')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_comments_path(filter: 'with_confirmed_hide')
    expect(page).to have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to_not have_link('Confirmed')
  end

  scenario "Filtering comments" do
    create(:comment, :hidden, body: "Unconfirmed comment")
    create(:comment, :hidden, :with_confirmed_hide, body: "Confirmed comment")

    visit admin_comments_path(filter: 'all')
    expect(page).to have_content('Unconfirmed comment')
    expect(page).to have_content('Confirmed comment')

    visit admin_comments_path(filter: 'with_confirmed_hide')
    expect(page).to_not have_content('Unconfirmed comment')
    expect(page).to have_content('Confirmed comment')
  end

  scenario "Action links remember the pagination setting and the filter" do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:comment, :hidden, :with_confirmed_hide) }

    visit admin_comments_path(filter: 'with_confirmed_hide', page: 2)

    click_on('Restore', match: :first, exact: true)

    expect(current_url).to include('filter=with_confirmed_hide')
    expect(current_url).to include('page=2')
  end

end
