require "rails_helper"

describe "Admin download user emails" do
  let(:admin_user) { create(:user, newsletter: false, email: "admin@consul.dev") }

  before do
    create(:administrator, user: admin_user)
    login_as(admin_user)
  end

  context "Download only emails from segment users with newsletter flag & present email " do
    before do
      create(:user, email: "user@consul.dev")

      create(:administrator, user: create(:user, newsletter: true, email: "admin_news1@consul.dev"))
      create(:administrator, user: create(:user, newsletter: true, email: "admin_news2@consul.dev"))

      create(:administrator, user: create(:user, newsletter: false, email: "no_news@consul.dev"))

      admin_without_email = create(:user, newsletter: true, email: "no_email@consul.dev")
      create(:administrator, user: admin_without_email)
      admin_without_email.update_column(:email, nil)
    end

    scenario "returns the selected users segment csv file" do
      visit admin_emails_download_index_path

      within("#admin_download_emails") do
        select "Administrators", from: "users_segment"
        click_button "Download emails list"
      end

      header = page.response_headers["Content-Disposition"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="Administrators.csv"$/)

      file_contents = page.body.split(",")
      expect(file_contents).to match_array ["admin_news1@consul.dev", "admin_news2@consul.dev"]
    end
  end

  scenario "Download button is not disabled after being clicked", :js do
    visit admin_emails_download_index_path
    click_button "Download emails list"

    expect(page).to have_button "Download emails list", disabled: false
  end
end
