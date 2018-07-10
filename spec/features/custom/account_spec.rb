require 'rails_helper'

feature 'Account' do

  background do
    Setting["org_name"] = 'MASDEMOCRACIAEUROPA'
    @user = create(:user, username: "Manuela Colau")
    login_as(@user)
  end

  scenario 'Show only display proposals information' do
    Setting["feature.user.skip_verification"] = 'true'

    visit root_path

    click_link "My account"

    expect(page).to have_content "Notify me by email when someone comments on my proposals"
    expect(page).not_to have_content "Notify me by email when someone comments on my proposals and debates"
    expect(page).to have_content I18n.t("welcome.welcome.user_permission_proposal_participate")
    expect(page).to have_content I18n.t("account.show.user_permission_proposal")
    expect(page).not_to have_content I18n.t("account.show.user_permission_support_proposal")
    expect(page).not_to have_content I18n.t("account.show.user_permission_votes")
    expect(page).not_to have_content I18n.t("account.show.user_permission_verify")

    Setting["feature.user.skip_verification"] = nil
  end

end
