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

   context "Search" do
 
     background do
       @usu1 = create(:user, email: 'enrique@madrid.es', 
                     password: '915885635', 
                     username: 'Enrique Ruiz Roldán', 
                     hidden_at: '016-01-25 13:04:01.021165',
                     phone_number: '915885635')
     end
 
     scenario "The search is not running if search is empty" do
       visit admin_users_path
       fill_in "search", with: "      "
       click_button "Search"
       expect(current_path).to eq(admin_users_path)
       expect(page).to have_content("Enrique Ruiz Roldán")
     end
 
     scenario "Returns no results if search does not exist" do
       visit admin_users_path
 
       fill_in "search", with: "Raul"
       click_button "Search"
       expect(current_path).to eq(admin_users_path)
       expect(page).to_not have_content("Raul")
       expect(page).to have_content("users cannot be found")
     end
     
     scenario "Finds by name" do
       visit admin_users_path
 
       fill_in "search", with: "Enrique"
       click_button "Search"
 
       expect(current_path).to eq(admin_users_path)
       expect(page).to have_content("Enrique Ruiz Roldán")
     end
   end

end
