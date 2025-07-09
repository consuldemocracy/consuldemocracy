require "rails_helper"

describe Dashboard::ResourcesComponent do
  let(:proposal) { create(:proposal, :draft) }

  before { sign_in(proposal.author) }

  describe "Available resources section" do
    let(:new_actions_since_last_login) { [] }

    describe "show available resources" do
      let!(:available) { create(:dashboard_action, :resource, :active) }
      let(:requested) { create(:dashboard_action, :resource, :admin_request, :active) }
      let(:executed_action) do
        create(
          :dashboard_executed_action,
          action: requested,
          proposal: proposal,
          executed_at: Time.current
        )
      end
      let(:solved) { create(:dashboard_action, :resource, :admin_request, :active) }
      let(:executed_solved_action) do
        create(
          :dashboard_executed_action,
          action: solved,
          proposal: proposal,
          executed_at: Time.current
        )
      end
      let!(:unavailable) do
        create(
          :dashboard_action,
          :resource,
          :active,
          required_supports: proposal.votes_for.size + 1_000
        )
      end

      before do
        create(:dashboard_administrator_task, :pending, source: executed_action)
        create(:dashboard_administrator_task, :done, source: executed_solved_action)
      end

      it "for proposal draft" do
        render_inline Dashboard::ResourcesComponent.new(proposal, new_actions_since_last_login)

        page.find("div.available-resources-section") do |available_resources_section|
          expect(available_resources_section).to have_content("Polls")
          expect(available_resources_section).to have_content("E-mail")
          expect(available_resources_section).to have_content("Poster")
          expect(available_resources_section).to have_content(available.title)
          expect(available_resources_section).to have_content(unavailable.title)
          expect(available_resources_section).to have_content(requested.title)
          expect(available_resources_section).to have_content(solved.title)

          page.find("div#dashboard_action_#{available.id}") do |dashboard_action_available|
            expect(dashboard_action_available).to have_link "See resource"
          end

          page.find("div#dashboard_action_#{requested.id}") do |dashboard_action_requested|
            expect(dashboard_action_requested).to have_content("Resource already requested")
          end

          page.find("div#dashboard_action_#{unavailable.id}") do |dashboard_action_unavailable|
            expect(dashboard_action_unavailable).to have_content("1.000 supports required")
          end

          page.find("div#dashboard_action_#{solved.id}") do |dashboard_action_solved|
            expect(dashboard_action_solved).to have_link("See resource")
          end
        end
      end

      it "for published proposal" do
        proposal.update!(published_at: Date.current)

        render_inline Dashboard::ResourcesComponent.new(proposal, new_actions_since_last_login)

        page.find("div.available-resources-section") do |available_resources_section|
          expect(available_resources_section).to have_content("Polls")
          expect(available_resources_section).to have_content("E-mail")
          expect(available_resources_section).to have_content("Poster")
          expect(available_resources_section).to have_content(available.title)
          expect(available_resources_section).to have_content(unavailable.title)
          expect(available_resources_section).to have_content(requested.title)
          expect(available_resources_section).to have_content(solved.title)

          page.find("div#dashboard_action_#{available.id}") do |dashboard_action_available|
            expect(dashboard_action_available).to have_link "See resource"
          end

          page.find("div#dashboard_action_#{requested.id}") do |dashboard_action_requested|
            expect(dashboard_action_requested).to have_content("Resource already requested")
          end

          page.find("div#dashboard_action_#{unavailable.id}") do |dashboard_action_unavailable|
            expect(dashboard_action_unavailable).to have_content("1.000 supports required")
          end

          page.find("div#dashboard_action_#{solved.id}") do |dashboard_action_solved|
            expect(dashboard_action_solved).to have_link("See resource")
          end
        end
      end
    end

    describe "do not show resources" do
      it "for proposal draft when resource has published_proposal: true" do
        available = create(:dashboard_action, :resource, :active, published_proposal: true)
        unavailable = create(:dashboard_action, :resource, :active,
                             required_supports: proposal.votes_for.size + 1_000,
                             published_proposal: true)

        render_inline Dashboard::ResourcesComponent.new(proposal, new_actions_since_last_login)

        page.find("div.available-resources-section") do |available_resources_section|
          expect(available_resources_section).to have_content("Polls")
          expect(available_resources_section).to have_content("E-mail")
          expect(available_resources_section).to have_content("Poster")
          expect(available_resources_section).not_to have_content(available.title)
          expect(available_resources_section).not_to have_content(unavailable.title)
        end
      end
    end
  end

  describe "Tags for new actions" do
    it "Display tag 'new' only when resouce is dectected like new action" do
      new_resource = create(:dashboard_action, :resource, :active)
      old_resource = create(:dashboard_action, :resource, :active)
      new_actions_since_last_login = [new_resource.id]

      render_inline Dashboard::ResourcesComponent.new(proposal, new_actions_since_last_login)

      page.find("div#dashboard_action_#{new_resource.id}") do |dashboard_action_new_resource|
        expect(dashboard_action_new_resource).to have_content("New")
      end

      page.find("div#dashboard_action_#{old_resource.id}") do |dashboard_action_old_resource|
        expect(dashboard_action_old_resource).not_to have_content("New")
      end
    end
  end
end
