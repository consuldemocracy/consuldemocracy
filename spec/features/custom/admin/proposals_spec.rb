require 'rails_helper'

feature 'Proposals' do

  background do
    Setting["org_name"] = 'MASDEMOCRACIAEUROPA'
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Menu" do

    scenario 'Should not display geozones menu entry' do
      visit admin_root_path

      expect(page).not_to have_link 'Manage geozones'
    end

  end
end
