require "rails_helper"

feature "Admin download user emails" do

  let(:admin_user) { create(:user, newsletter: false, email: "admin@consul.dev") }

  background do
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
      admin_without_email.update_attribute(:email, nil)
    end

    scenario "returns the selected users segment csv file" do
      visit admin_emails_download_index_path

      within("#admin_download_emails") do
        select "Administrators", from: "users_segment"
        click_button "Download emails list"
      end

      header = page.response_headers["Content-Disposition"]
      expect(header).to match /^attachment/
      expect(header).to match /filename="Administrators.csv"$/

      file_contents = page.body.split(",")
      expect(file_contents.count).to eq(2)
      expect(file_contents).to include("admin_news1@consul.dev")
      expect(file_contents).to include("admin_news2@consul.dev")
      expect(file_contents).not_to include("admin@consul.dev")
      expect(file_contents).not_to include("user@consul.dev")
      expect(file_contents).not_to include("no_news@consul.dev")
      expect(file_contents).not_to include("no_email@consul.dev")
    end
  end
end
