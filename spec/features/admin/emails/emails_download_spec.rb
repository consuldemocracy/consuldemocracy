require 'rails_helper'

feature "Admin download user emails" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do
    scenario "returns the selected users segment csv file" do
      user1 = create(:user)
      user2 = create(:user)

      visit admin_emails_download_index_path

      within('#admin_download_emails') do
        select 'All users', from: 'users_segment'
        click_button 'Download emails list'
      end

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /filename="All users.csv"$/

      expect(page).to have_content(user1.email)
      expect(page).to have_content(user2.email)
    end
  end
end
