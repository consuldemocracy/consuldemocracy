require 'rails_helper'

feature 'Admin moderators' do
  background do
    @user = create(:user)
    @moderator = create(:moderator)
    @admin = create(:administrator)
    login_as(@admin)
  end

  scenario 'Index' do
    visit admin_moderators_path
  end
end

