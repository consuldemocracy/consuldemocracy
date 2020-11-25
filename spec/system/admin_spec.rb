require "rails_helper"

describe "Admin" do
  let(:user) { create(:user) }

  scenario "Access as regular user is not authorized" do
    login_as(user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as moderator is not authorized" do
    create(:moderator, user: user)
    login_as(user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as valuator is not authorized" do
    create(:valuator, user: user)
    login_as(user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as manager is not authorized" do
    create(:manager, user: user)
    login_as(user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as SDG manager is not authorized", :js do
    create(:sdg_manager, user: user)
    login_as(user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as poll officer is not authorized" do
    login_as(create(:poll_officer).user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as administrator is authorized", :admin do
    visit admin_root_path

    expect(page).to have_current_path(admin_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Admin access links", :admin do
    Setting["feature.sdg"] = true

    visit root_path

    expect(page).to have_link("Administration")
    expect(page).to have_link("Moderation")
    expect(page).to have_link("Valuation")
    expect(page).to have_link("Management")
    expect(page).to have_link("SDG content")
  end

  scenario "Admin dashboard", :admin do
    visit root_path

    click_link "Administration"

    expect(page).to have_current_path(admin_root_path)
    expect(page).to have_css("#admin_menu")
    expect(page).not_to have_css("#moderation_menu")
    expect(page).not_to have_css("#valuation_menu")
  end

  scenario "Admin menu does not hide active elements", :js, :admin do
    visit admin_budgets_path

    within("#admin_menu") do
      expect(page).to have_link "Participatory budgets"

      click_link "Site content"

      expect(page).to have_link "Participatory budgets"
    end
  end
end
