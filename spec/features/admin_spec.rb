require "rails_helper"

feature "Admin" do
  let(:user) { create(:user) }
  let(:administrator) do
    create(:administrator, user: user)
    user
  end

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

  scenario "Access as poll officer is not authorized" do
    create(:poll_officer, user: user)
    login_as(user)
    visit admin_root_path

    expect(page).not_to have_current_path(admin_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as administrator is authorized" do
    login_as(administrator)
    visit admin_root_path

    expect(page).to have_current_path(admin_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Admin access links" do
    Setting["feature.spending_proposals"] = true

    login_as(administrator)
    visit root_path

    expect(page).to have_link("Administration")
    expect(page).to have_link("Moderation")
    expect(page).to have_link("Valuation")
    expect(page).to have_link("Management")

    Setting["feature.spending_proposals"] = nil
  end

  scenario "Admin dashboard" do
    login_as(administrator)
    visit root_path

    click_link "Administration"

    expect(page).to have_current_path(admin_root_path)
    expect(page).to have_css("#admin_menu")
    expect(page).not_to have_css("#moderation_menu")
    expect(page).not_to have_css("#valuation_menu")
  end

end
