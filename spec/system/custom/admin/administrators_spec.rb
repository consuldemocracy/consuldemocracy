require "rails_helper"

describe "Admin administrators" do
  let(:admin) { create(:administrator) }
  let(:user_administrator) { create(:administrator, description: "admin_alias") }

  before { login_as(admin.user) }

  scenario "Delete Administrator when it is assigned to a budget" do
    create(:budget, administrators: [user_administrator])

    visit admin_administrators_path

    within "#administrator_#{user_administrator.id}" do
      accept_confirm { click_button "Delete" }
    end

    within("#administrators") do
      expect(page).not_to have_content user_administrator.name
    end
  end
end
