require "rails_helper"

describe Dashboard::ResourcesComponent do
  let(:proposal) { create(:proposal, :draft) }
  before { sign_in(proposal.author) }

  describe "Available resources section" do
    let!(:available) { create(:dashboard_action, :resource, :active, title: "Available!") }
    let(:requested) { create(:dashboard_action, :resource, :admin_request, :active, title: "Requested!") }
    let(:executed_action) do
      create(
        :dashboard_executed_action,
        action: requested,
        proposal: proposal,
        executed_at: Time.current
      )
    end
    let(:solved) { create(:dashboard_action, :resource, :admin_request, :active, title: "Solved!") }
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
        required_supports: proposal.votes_for.size + 1_000,
        title: "Unavailable!"
      )
    end

    before do
      create(:dashboard_administrator_task, :pending, source: executed_action)
      create(:dashboard_administrator_task, :done, source: executed_solved_action)
    end

    it "shows available resources for proposal drafts" do
      render_inline Dashboard::ResourcesComponent.new(proposal)

      expect(page).to have_content "Polls"
      expect(page).to have_content "E-mail"
      expect(page).to have_content "Poster"
      expect(page).to have_content available.title
      expect(page).to have_content unavailable.title
      expect(page).to have_content requested.title
      expect(page).to have_content solved.title

      page.find(".resource-card", text: "Available!") do |dashboard_action_available|
        expect(dashboard_action_available).to have_link "See resource"
      end

      page.find(".resource-card", text: "Requested!") do |dashboard_action_requested|
        expect(dashboard_action_requested).to have_content "Resource already requested"
      end

      page.find(".resource-card", text: "Unavailable!") do |dashboard_action_unavailable|
        expect(dashboard_action_unavailable).to have_content "1.000 supports required"
      end

      page.find(".resource-card", text: "Solved!") do |dashboard_action_solved|
        expect(dashboard_action_solved).to have_link "See resource"
      end
    end

    it "shows available resources for published proposals" do
      proposal.update!(published_at: Date.current)

      render_inline Dashboard::ResourcesComponent.new(proposal)

      expect(page).to have_content "Polls"
      expect(page).to have_content "E-mail"
      expect(page).to have_content "Poster"
      expect(page).to have_content available.title
      expect(page).to have_content unavailable.title
      expect(page).to have_content requested.title
      expect(page).to have_content solved.title

      page.find(".resource-card", text: "Available!") do |dashboard_action_available|
        expect(dashboard_action_available).to have_link "See resource"
      end

      page.find(".resource-card", text: "Requested!") do |dashboard_action_requested|
        expect(dashboard_action_requested).to have_content "Resource already requested"
      end

      page.find(".resource-card", text: "Unavailable!") do |dashboard_action_unavailable|
        expect(dashboard_action_unavailable).to have_content "1.000 supports required"
      end

      page.find(".resource-card", text: "Solved!") do |dashboard_action_solved|
        expect(dashboard_action_solved).to have_link "See resource"
      end
    end

    it "does not show resources with published_proposal: true" do
      available.update!(published_proposal: true)
      unavailable.update!(published_proposal: true)

      render_inline Dashboard::ResourcesComponent.new(proposal)

      expect(page).to have_content "Polls"
      expect(page).to have_content "E-mail"
      expect(page).to have_content "Poster"
      expect(page).not_to have_content available.title
      expect(page).not_to have_content unavailable.title
    end
  end

  describe "Tags for new actions" do
    it "displays tag 'new' only when resource is detected like new action" do
      create(:dashboard_action, :resource, :active, title: "Old!")
      new_resource = create(:dashboard_action, :resource, :active, title: "Recent!")
      new_actions_since_last_login = [new_resource.id]

      render_inline Dashboard::ResourcesComponent.new(proposal, new_actions_since_last_login)

      page.find(".resource-card", text: "Recent!") do |dashboard_action_new_resource|
        expect(dashboard_action_new_resource).to have_content "New"
      end

      page.find(".resource-card", text: "Old!") do |dashboard_action_old_resource|
        expect(dashboard_action_old_resource).not_to have_content "New"
      end
    end
  end
end
