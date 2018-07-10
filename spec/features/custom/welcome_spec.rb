require 'rails_helper'

feature "Welcome screen" do

  before do
    Setting["org_name"] = 'MASDEMOCRACIAEUROPA'
  end

  scenario 'a regular users sees it the first time he logs in, with all options active
            if the setting skip_verification is activated' do
      Setting["feature.user.skip_verification"] = 'true'
      user = create(:user)
      login_through_form_as(user)

      expect(page).to have_content "Participate on proposals"
      expect(page).to have_content "Create new proposals"
      expect(page).to have_content "See proposals"
      expect(page).not_to have_content I18n.t("welcome.welcome.user_permission_support_proposal")
      expect(page).not_to have_content I18n.t("welcome.welcome.user_permission_votes")
      expect(page).not_to have_content I18n.t("welcome.welcome.user_permission_verify_info")
      expect(page).not_to have_content I18n.t("welcome.welcome.user_permission_verify")
      expect(page).not_to have_content I18n.t("welcome.welcome.user_permission_verify_my_account")

      Setting["feature.user.skip_verification"] = nil
  end
end
