require "rails_helper"

include ActionView::RecordIdentifier

describe "Moderation" do
  let(:user) { create(:user) }

  describe "Access" do
    context "for regular users, valuators, managers, SDG managers and poll officers" do
      let(:factory) { [:user, :valuator, :manager, :sdg_manager, :poll_officer].sample }

      before { create(factory, user: user) if factory != :user }

      scenario "is not authorized" do
        login_as(user)
        visit moderation_root_path

        expect(page).not_to have_current_path moderation_root_path
        expect(page).to have_current_path root_path
        expect(page).to have_content "You do not have permission to access this page"
      end
    end

    context "for moderators and administrators" do
      let(:factory) { [:moderator, :administrator].sample }

      scenario "is authorized" do
        Setting["org_name"] = "OrgName"
        create(factory, user: user)

        login_as(user)
        visit root_path
        click_link "Menu"
        click_link "Moderation"

        expect(page).to have_current_path moderation_root_path
        expect(page).to have_link "Go back to OrgName"
        expect(page).to have_css "#moderation_menu"
        expect(page).not_to have_css "#admin_menu"
        expect(page).not_to have_css "#valuation_menu"
        expect(page).not_to have_content "You do not have permission to access this page"
      end
    end
  end

  describe "Moderate resources" do
    factories = [
      :budget_investment,
      :comment,
      :debate,
      :legislation_proposal,
      :proposal,
      :proposal_notification
    ]

    let(:factory) { factories.sample }
    let!(:resource) { create(factory) }
    let(:moderator) { create(:moderator) }
    let(:resource_path) do
      if factory == :proposal_notification
        polymorphic_path(resource.proposal, anchor: "tab-notifications")
      else
        polymorphic_path(resource)
      end
    end
    let(:faded_selector) { factory == :comment ? "> .comment-body.faded" : ".faded" }
    let(:order) { factory == :comment ? "newest" : "created_at" }

    scenario "Hide", :show_exceptions do
      login_as moderator.user
      visit resource_path

      within "##{dom_id(resource)}" do
        accept_confirm("Are you sure? Hide") { click_button "Hide" }
      end

      expect(page).to have_css "##{dom_id(resource)}#{faded_selector}"
      if factory != :comment && factory != :proposal_notification
        expect(page).to have_css "#comments.faded"
      end
      expect(page).to have_content resource.human_name

      refresh

      expect(page).not_to have_content resource.human_name

      if factory == :proposal_notification
        expect(page).to have_content "Notifications (0)"
      else
        expect(page).to have_content "Not found"
      end
    end

    scenario "Hiding a resource's author" do
      login_as(moderator.user)
      visit resource_path

      within "##{dom_id(resource)}" do
        accept_confirm("Are you sure? This will hide the user \"#{resource.author.name}\" " \
                       "and all their contents.") do
          click_button "Block author"
        end
      end

      expect(page).to have_content "The user has been blocked"
      expect(page).not_to have_content resource.human_name
    end

    describe "/moderation/ screen" do
      let(:pending_filter) { factory == :proposal_notification ? "pending_review" : "pending_flag_review" }
      let(:ignored_filter) { factory == :proposal_notification ? "ignored" : "with_ignored_flag" }

      before { login_as moderator.user }

      describe "moderate in bulk" do
        describe "When a resource has been selected for moderation" do
          before do
            visit moderation_resource_index_path
            click_link "All"

            check resource.human_name
          end

          scenario "Hide the resource" do
            accept_confirm(/Are you sure\? Hide /) do
              click_button "Hide ", exact: false
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

            if factory == :proposal_notification
              expect(resource.reload).to be_ignored
            else
              expect(resource.reload).to be_ignored_flag
            end
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

          if factory == :proposal_notification
            expect(page).to have_link "Moderated"
          else
            expect(page).to have_link "Most flagged"
          end

          expect(page).to have_current_path(/filter=all/)
          expect(page).to have_current_path(/page=2/)
          expect(page).to have_current_path(/order=#{order}/)
        end
      end

      scenario "Filtering resources" do
        regular_resource = create(factory)
        hidden_resource = create(factory, :hidden)
        if factory == :proposal_notification
          pending_resource = create(factory, :moderated)
          ignored_resource = create(factory, :moderated, :ignored)
        else
          pending_resource = create(factory, :flagged)
          ignored_resource = create(factory, :flagged, :with_ignored_flag)
        end

        visit moderation_resource_index_path(filter: "all")
        expect(page).to have_content regular_resource.human_name
        expect(page).to have_content pending_resource.human_name
        expect(page).not_to have_content hidden_resource.human_name
        expect(page).to have_content ignored_resource.human_name

        visit moderation_resource_index_path(filter: pending_filter)
        expect(page).not_to have_content regular_resource.human_name
        expect(page).to have_content pending_resource.human_name
        expect(page).not_to have_content hidden_resource.human_name
        expect(page).not_to have_content ignored_resource.human_name

        visit moderation_resource_index_path(filter: ignored_filter)
        expect(page).not_to have_content regular_resource.human_name
        expect(page).not_to have_content pending_resource.human_name
        expect(page).not_to have_content hidden_resource.human_name
        expect(page).to have_content ignored_resource.human_name
      end

      context "Budget Investments, Comments, Debates, Legislation Proposals and Proposals" do
        let(:factory) { (factories - [:proposal_notification]).sample }

        scenario "Sorting resources" do
          flagged_resource = create(factory, created_at: 1.day.ago, flags_count: 5)
          flagged_new_resource = create(factory, created_at: 12.hours.ago, flags_count: 3)
          newer_resource = create(factory, created_at: Time.current)

          visit moderation_resource_index_path(order: order)

          expect(flagged_new_resource.human_name).to appear_before flagged_resource.human_name

          visit moderation_resource_index_path(order: "flags")

          expect(flagged_resource.human_name).to appear_before flagged_new_resource.human_name

          visit moderation_resource_index_path(filter: "all", order: order)

          expect(newer_resource.human_name).to appear_before flagged_new_resource.human_name
          expect(flagged_new_resource.human_name).to appear_before flagged_resource.human_name

          visit moderation_resource_index_path(filter: "all", order: "flags")

          expect(flagged_resource.human_name).to appear_before flagged_new_resource.human_name
          expect(flagged_new_resource.human_name).to appear_before newer_resource.human_name
        end
      end

      context "Proposal Notifications" do
        scenario "Sorting resources" do
          moderated_notification = create(:proposal_notification, :moderated, created_at: 1.day.ago)
          moderated_new_notification = create(:proposal_notification, :moderated, created_at: 12.hours.ago)
          newer_notification = create(:proposal_notification, created_at: Time.current)
          old_moderated_notification = create(:proposal_notification, :moderated, created_at: 2.days.ago)

          visit moderation_proposal_notifications_path(filter: "all", order: "created_at")

          expect(newer_notification.title).to appear_before moderated_notification.title
          expect(moderated_new_notification.title).to appear_before moderated_notification.title
          expect(moderated_notification.title).to appear_before old_moderated_notification.title

          visit moderation_proposal_notifications_path(filter: "all", order: "moderated")

          expect(old_moderated_notification.title).to appear_before newer_notification.title
        end
      end

      scenario "Visit flagged resources" do
        if factory == :proposal_notification
          reported_resource = create(factory)
        else
          reported_resource = create(factory, :flagged)
        end
        login_as(moderator.user)

        visit moderation_resource_index_path(filter: "all")

        expect(page).to have_content "Moderation"
        expect(page).to have_content reported_resource.human_name

        if factory == :comment
          click_link reported_resource.commentable.title
        else
          click_link reported_resource.title
        end

        expect(page).not_to have_content "Moderation"
        expect(page).to have_content reported_resource.human_name
      end
    end
  end

  def moderation_resource_index_path(params = {})
    namespaced_polymorphic_path(:moderation, resource.class, **params)
  end
end
