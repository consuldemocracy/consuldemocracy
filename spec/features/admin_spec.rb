require 'rails_helper'

feature 'Admin' do
  let(:user) { create(:user) }

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit admin_root_path

    expect(current_path).to eq(root_path)
    expect(page).to have_content "not authorized"
  end

  scenario 'Access as a moderator is not authorized' do
    create(:moderator, user: user)

    login_as(user)
    visit admin_root_path

    expect(current_path).to eq(root_path)
    expect(page).to have_content "not authorized"
  end

  scenario 'Access as an administrator is authorized' do
    create(:administrator, user: user)

    login_as(user)
    visit admin_root_path

    expect(current_path).to eq(admin_root_path)
    expect(page).to_not have_content "not authorized"
  end

end
