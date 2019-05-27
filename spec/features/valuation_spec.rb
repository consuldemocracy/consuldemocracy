require "rails_helper"

feature "Valuation" do
  let(:user) { create(:user) }

  context "Access" do
    scenario "Access as regular user is not authorized" do
      login_as(user)
      visit root_path

      expect(page).not_to have_link("Valuation")
      visit valuation_root_path

      expect(page).not_to have_current_path(valuation_root_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Access as moderator is not authorized" do
      create(:moderator, user: user)
      login_as(user)
      visit root_path

      expect(page).not_to have_link("Valuation")
      visit valuation_root_path

      expect(page).not_to have_current_path(valuation_root_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Access as manager is not authorized" do
      create(:manager, user: user)
      login_as(user)
      visit root_path

      expect(page).not_to have_link("Valuation")
      visit valuation_root_path

      expect(page).not_to have_current_path(valuation_root_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Access as poll officer is not authorized" do
      create(:poll_officer, user: user)
      login_as(user)
      visit root_path

      expect(page).not_to have_link("Valuation")
      visit valuation_root_path

      expect(page).not_to have_current_path(valuation_root_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Access as a valuator is authorized" do
      create(:valuator, user: user)
      create(:budget)

      login_as(user)
      visit root_path

      expect(page).to have_link("Valuation")
      click_on "Valuation"

      expect(page).to have_current_path(valuation_root_path)
      expect(page).not_to have_content "You do not have permission to access this page"
    end

    scenario "Access as an administrator is authorized" do
      create(:administrator, user: user)
      create(:budget)

      login_as(user)
      visit root_path

      expect(page).to have_link("Valuation")
      click_on "Valuation"

      expect(page).to have_current_path(valuation_root_path)
      expect(page).not_to have_content "You do not have permission to access this page"
    end
  end

  scenario "Valuation access links" do
    create(:valuator, user: user)
    create(:budget)

    login_as(user)
    visit root_path

    expect(page).to have_link("Valuation")
    expect(page).not_to have_link("Administration")
    expect(page).not_to have_link("Moderation")
  end

  scenario "Valuation dashboard" do
    create(:valuator, user: user)
    create(:budget)

    login_as(user)
    visit root_path

    click_link "Valuation"

    expect(page).to have_current_path(valuation_root_path)
    expect(page).to have_css("#valuation_menu")
    expect(page).not_to have_css("#admin_menu")
    expect(page).not_to have_css("#moderation_menu")
  end

end
