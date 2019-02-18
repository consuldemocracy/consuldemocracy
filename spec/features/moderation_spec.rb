require "rails_helper"

feature "Moderation" do
  let(:user) { create(:user) }

  scenario "Access as regular user is not authorized" do
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Moderation")
    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as valuator is not authorized" do
    create(:valuator, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Moderation")
    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as manager is not authorized" do
    create(:manager, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Moderation")
    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as poll officer is not authorized" do
    create(:poll_officer, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Moderation")
    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as a moderator is authorized" do
    create(:moderator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link("Moderation")
    click_on "Moderation"

    expect(page).to have_current_path(moderation_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Access as an administrator is authorized" do
    create(:administrator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link("Moderation")
    click_on "Moderation"

    expect(page).to have_current_path(moderation_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Moderation access links" do
    create(:moderator, user: user)
    login_as(user)
    visit root_path

    expect(page).to have_link("Moderation")
    expect(page).not_to have_link("Administration")
    expect(page).not_to have_link("Valuation")
  end

  context "Moderation dashboard" do
    background do
      Setting["org_name"] = "OrgName"
    end

    after do
      Setting["org_name"] = "CONSUL"
    end

    scenario "Contains correct elements" do
      create(:moderator, user: user)
      login_as(user)
      visit root_path

      click_link "Moderation"

      expect(page).to have_link("Go back to OrgName")
      expect(page).to have_current_path(moderation_root_path)
      expect(page).to have_css("#moderation_menu")
      expect(page).not_to have_css("#admin_menu")
      expect(page).not_to have_css("#valuation_menu")
    end
  end
end
