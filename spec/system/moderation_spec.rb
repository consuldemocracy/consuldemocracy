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
    let!(:resource) { create(factory) }
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

    scenario "Can not hide own resource" do
      resource.update(author: moderator.user)

      login_as moderator.user
      visit resource_path

      within "##{dom_id(resource)}" do
        expect(page).not_to have_button "Hide"
        expect(page).not_to have_button "Block author"
      end
    end

    describe "/moderation/ screen" do
      let(:moderation_resource_index_path) { send("moderation_#{factory.to_s.pluralize}_path") }

      before { login_as moderator.user }

      describe "moderate in bulk" do
        describe "When a resource has been selected for moderation" do
          before do
            visit moderation_resource_index_path
            click_link "All"

            check resource.title
          end

          scenario "Hide the resource" do
            accept_confirm("Are you sure? Hide #{factory.to_s.pluralize}") do
              click_button "Hide #{factory.to_s.pluralize}"
            end

            expect(page).not_to have_css "##{dom_id(resource)}"

            click_link "Block users"
            fill_in "email or name of user", with: resource.author.email
            click_button "Search"

            within "tr", text: resource.author.name do
              expect(page).to have_button "Block"
            end
          end

          scenario "Block the author" do
            accept_confirm("Are you sure? Block authors") { click_button "Block authors" }

            expect(page).not_to have_css "##{dom_id(resource)}"

            click_link "Block users"
            fill_in "email or name of user", with: resource.author.email
            click_button "Search"

            within "tr", text: resource.author.name do
              expect(page).to have_content "Blocked"
            end
          end

          scenario "Ignore the resource", :no_js do
            click_button "Mark as viewed"

            expect(resource.reload).to be_ignored_flag
            expect(resource.reload).not_to be_hidden
            expect(resource.author).not_to be_hidden
          end
        end
      end
    end
  end
end
