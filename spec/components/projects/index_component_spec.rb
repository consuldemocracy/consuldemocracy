require "rails_helper"

describe Projects::IndexComponent, controller: ProjectsController do
  Setting["process.projects"] = true

  describe "#active" do
    before do
      allow(vc_test_controller).to receive_messages(valid_filters: ["active"], current_filter: "active")
    end
    let(:project) { create(:project, title: "IndexProject") }

    it "info when no active projects" do
      project.update(state: 'draft')
      render_inline Projects::IndexComponent.new(Project.published.page(1))

      expect(page).to have_content "No projects available yet."
    end

    it "display active project" do
      project.update(state: 'active')
      render_inline Projects::IndexComponent.new(Project.active.page(1))

      expect(page).to have_content "IndexProject"
    end
  end

  describe "#archived" do
    before do
      allow(vc_test_controller).to receive_messages(valid_filters: ["archived"], current_filter: "archived")
    end
    let(:project) { create(:project, title: "IndexProject") }

    it "info when no archived projects" do
      project.update(state: 'draft')
      render_inline Projects::IndexComponent.new(Project.published.page(1))

      expect(page).to have_content "No projects available yet."
    end

    it "display archived project" do
      project.update(state: 'archived')
      render_inline Projects::IndexComponent.new(Project.archived.page(1))

      expect(page).to have_content "IndexProject"
    end
  end
end