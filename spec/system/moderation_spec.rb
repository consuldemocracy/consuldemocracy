require "rails_helper"

include ActionView::RecordIdentifier

describe "Moderation" do
  let(:user) { create(:user) }

  scenario "Access as regular user is not authorized" do
    login_as(user)

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as valuator is not authorized" do
    create(:valuator, user: user)
    login_as(user)

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as manager is not authorized" do
    create(:manager, user: user)
    login_as(user)

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as SDG manager is not authorized" do
    create(:sdg_manager, user: user)
    login_as(user)

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as poll officer is not authorized" do
    create(:poll_officer, user: user)
    login_as(user)

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as a moderator is authorized" do
    Setting["org_name"] = "OrgName"
    create(:moderator, user: user)

    login_as(user)
    visit root_path
    click_link "Menu"
    click_link "Moderation"

    expect(page).to have_current_path(moderation_root_path)
    expect(page).to have_link "Go back to OrgName"
    expect(page).to have_css "#moderation_menu"
    expect(page).not_to have_css "#admin_menu"
    expect(page).not_to have_css "#valuation_menu"
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Access as an administrator is authorized" do
    create(:administrator, user: user)

    login_as(user)
    visit root_path
    click_link "Menu"
    click_link "Moderation"

    expect(page).to have_current_path(moderation_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  describe "Moderate resources" do
    factories = [
      :debate,
      :proposal
    ]

    let(:factory) { factories.sample }
    let(:resource) { create(factory) }
    let(:moderator) { create(:moderator) }
    let(:index_path) { polymorphic_path(factory.to_s.pluralize) }
    let(:resource_path) { polymorphic_path(resource) }

    scenario "Hide" do
      login_as moderator.user
      visit resource_path

      within "##{dom_id(resource)}" do
        accept_confirm("Are you sure? Hide") { click_button "Hide" }
      end

      expect(page).to have_css "##{dom_id(resource)}.faded"
      expect(page).to have_content resource.title

      login_as user
      visit index_path

      expect(page).not_to have_content resource.title
      expect(page).to have_css(".#{factory}", count: 0)
    end
  end
end
