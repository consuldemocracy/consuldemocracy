require 'rails_helper'

feature 'Admin users' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Show user activity' do
    user = create(:user, :hidden)

    debate1 = create(:debate, :hidden, author: user)
    debate2 = create(:debate, author: user)
    comment1 = create(:comment, :hidden, user: user, commentable: debate2, body: "You have the manners of a beggar")
    comment2 = create(:comment, user: user, commentable: debate2, body: 'Not Spam')

    visit admin_user_path(user)

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(comment1.body)
    expect(page).to have_content(comment2.body)
  end

  scenario 'Show user activity2' do
    user = create(:user, :hidden)

    medida1 = create(:medida, :hidden, author: user)
    medida2 = create(:medida, author: user)
    comment1 = create(:comment, :hidden, user: user, commentable: medida2, body: "You have the manners of a beggar")
    comment2 = create(:comment, user: user, commentable: medida2, body: 'Not Spam')

    visit admin_user_path(user)

    expect(page).to have_content(medida1.title)
    expect(page).to have_content(medida2.title)
    expect(page).to have_content(comment1.body)
    expect(page).to have_content(comment2.body)
  end

  scenario 'Restore' do
    user = create(:user, :hidden)
    visit admin_users_path

    click_link 'Restore'

    expect(page).to_not have_content(user.username)

    expect(user.reload).to_not be_hidden
  end

  scenario 'Confirm hide' do
    user = create(:user, :hidden)
    visit admin_users_path

    click_link 'Confirm'

    expect(page).to_not have_content(user.username)
    click_link('Confirmed')
    expect(page).to have_content(user.username)

    expect(user.reload).to be_confirmed_hide
  end

  scenario "Current filter is properly highlighted" do
    visit admin_users_path
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_users_path(filter: 'Pending')
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_users_path(filter: 'all')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_users_path(filter: 'with_confirmed_hide')
    expect(page).to have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('Confirmed')
  end

  scenario "Filtering users" do
    create(:user, :hidden, username: "Unconfirmed")
    create(:user, :hidden, :with_confirmed_hide, username: "Confirmed user")

    visit admin_users_path(filter: 'all')
    expect(page).to have_content('Unconfirmed')
    expect(page).to have_content('Confirmed user')

    visit admin_users_path(filter: 'with_confirmed_hide')
    expect(page).to_not have_content('Unconfirmed')
    expect(page).to have_content('Confirmed user')
  end

  scenario "Action links remember the pagination setting and the filter" do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:user, :hidden, :with_confirmed_hide) }

    visit admin_users_path(filter: 'with_confirmed_hide', page: 2)

    click_on('Restore', match: :first, exact: true)

    expect(current_url).to include('filter=with_confirmed_hide')
    expect(current_url).to include('page=2')
  end

end
