require 'rails_helper'

feature 'Admin debates' do

  scenario 'Restore', :js do
    citizen = create(:user)
    admin = create(:administrator)

    debate = create(:debate, :hidden)

    login_as(admin.user)
    visit admin_debate_path(debate)

    click_link 'Restore'

    expect(page).to have_content 'The debate has been restored'

    login_as(citizen)
    visit debates_path

    expect(page).to have_css('.debate', count: 1)
  end
end
