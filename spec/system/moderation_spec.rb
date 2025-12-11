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
      :budget_investment,
      :debate,
      :proposal
    ]

    let(:factory) { factories.sample }
    let!(:resource) { create(factory) }
    let(:moderator) { create(:moderator) }
    let(:index_path) do
      if factory == :budget_investment
        polymorphic_path([resource.budget, :investments])
      elsif factory == :comment
        polymorphic_path(resource.commentable)
      else
        polymorphic_path(factory.to_s.pluralize)
      end
    end
    let(:resource_path) { polymorphic_path(resource) }
    let(:faded_selector) { factory == :comment ? "> .comment-body.faded" : ".faded" }

    scenario "Hide" do
      login_as moderator.user
      visit resource_path

      within "##{dom_id(resource)}" do
        accept_confirm("Are you sure? Hide") { click_button "Hide" }
      end

      expect(page).to have_css "##{dom_id(resource)}#{faded_selector}"
      expect(page).to have_css "#comments.faded" unless factory == :comment
      expect(page).to have_content resource.human_name

      login_as user
      visit index_path

      if factory == :comment
        expect(page).to have_css(".comment", count: 1)
      else
        expect(page).to have_css(".#{factory}", count: 0)
      end
      expect(page).not_to have_content resource.human_name
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

    scenario "Hiding a resource's author" do
      login_as(moderator.user)
      visit resource_path

      accept_confirm("Are you sure? This will hide the user \"#{resource.author.name}\" " \
                     "and all their contents.") do
        click_button "Block author"
      end

      expect(page).to have_current_path index_path
      expect(page).not_to have_content resource.human_name
    end

    describe "/moderation/ screen" do
      before { login_as moderator.user }

      describe "moderate in bulk" do
        describe "When a resource has been selected for moderation" do
          before do
            visit moderation_resource_index_path
            click_link "All"

            check resource.human_name
          end

          scenario "Hide the resource" do
            accept_confirm("Are you sure? Hide #{factory.to_s.pluralize.tr("_", " ")}") do
              click_button "Hide #{factory.to_s.pluralize.tr("_", " ")}"
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

        scenario "select all/none" do
          create_list(factory, 2)

          visit moderation_resource_index_path
          click_link "All"

          expect(page).to have_field type: :checkbox, count: 3

          within(".check-all-none") { click_button "Select all" }

          expect(all(:checkbox)).to all be_checked

          within(".check-all-none") { click_button "Select none" }

          all(:checkbox).each { |checkbox| expect(checkbox).not_to be_checked }
        end

        scenario "remembering page, filter and order" do
          order = factory == :comment ? "newest" : "created_at"
          stub_const("#{ModerateActions}::PER_PAGE", 2)
          create_list(factory, 4)

          visit moderation_resource_index_path(filter: "all", page: "2", order: order)

          within("table") { check first(:checkbox)[:id] }
          accept_confirm("Are you sure? Mark as viewed") { click_button "Mark as viewed" }

          within("table") do
            all(:checkbox).each { |checkbox| expect(checkbox).not_to be_checked }
          end

          if factory == :debate || factory == :comment
            expect(page).to have_link "Newest", class: "is-active"
          else
            expect(page).to have_link "Most recent", class: "is-active"
          end
          expect(page).to have_link "Most flagged"

          expect(page).to have_current_path(/filter=all/)
          expect(page).to have_current_path(/page=2/)
          expect(page).to have_current_path(/order=#{order}/)
        end
      end

      scenario "Current filter is properly highlighted" do
        visit moderation_resource_index_path
        expect(page).not_to have_link "Pending"
        expect(page).to have_link "All"
        expect(page).to have_link "Marked as viewed"

        visit moderation_resource_index_path(filter: "all")
        expect(page).not_to have_link "All"
        expect(page).to have_link "Pending"
        expect(page).to have_link "Marked as viewed"

        visit moderation_resource_index_path(filter: "pending_flag_review")
        expect(page).to have_link "All"
        expect(page).not_to have_link "Pending"
        expect(page).to have_link "Marked as viewed"

        visit moderation_resource_index_path(filter: "with_ignored_flag")
        expect(page).to have_link "All"
        expect(page).to have_link "Pending"
        expect(page).not_to have_link "Marked as viewed"
      end

      scenario "Filtering resources" do
        regular_resource = create(factory)
        pending_resource = create(factory, :flagged)
        hidden_resource = create(factory, :hidden)
        ignored_resource = create(factory, :flagged, :with_ignored_flag)

        visit moderation_resource_index_path(filter: "all")
        expect(page).to have_content content_for(regular_resource)
        expect(page).to have_content content_for(pending_resource)
        expect(page).not_to have_content content_for(hidden_resource)
        expect(page).to have_content content_for(ignored_resource)

        visit moderation_resource_index_path(filter: "pending_flag_review")
        expect(page).not_to have_content content_for(regular_resource)
        expect(page).to have_content content_for(pending_resource)
        expect(page).not_to have_content content_for(hidden_resource)
        expect(page).not_to have_content content_for(ignored_resource)

        visit moderation_resource_index_path(filter: "with_ignored_flag")
        expect(page).not_to have_content content_for(regular_resource)
        expect(page).not_to have_content content_for(pending_resource)
        expect(page).not_to have_content content_for(hidden_resource)
        expect(page).to have_content content_for(ignored_resource)
      end

      scenario "Sorting resources" do
        flagged_resource = create(factory, title: "Flagged resource", created_at: 1.day.ago, flags_count: 5)
        flagged_new_resource = create(factory,
                                      title: "Flagged new resource",
                                      created_at: 12.hours.ago,
                                      flags_count: 3)
        newer_resource = create(factory, title: "Newer resource", created_at: Time.current)

        visit moderation_resource_index_path(order: "created_at")

        expect(flagged_new_resource.title).to appear_before flagged_resource.title

        visit moderation_resource_index_path(order: "flags")

        expect(flagged_resource.title).to appear_before flagged_new_resource.title

        visit moderation_resource_index_path(filter: "all", order: "created_at")

        expect(newer_resource.title).to appear_before flagged_new_resource.title
        expect(flagged_new_resource.title).to appear_before flagged_resource.title

        visit moderation_resource_index_path(filter: "all", order: "flags")

        expect(flagged_resource.title).to appear_before flagged_new_resource.title
        expect(flagged_new_resource.title).to appear_before newer_resource.title
      end
    end
  end

  def moderation_resource_index_path(params = {})
    namespaced_polymorphic_path(:moderation, resource.class, **params)
  end

  def content_for(resource)
    factory == :comment ? resource.body : resource.title
  end
end
