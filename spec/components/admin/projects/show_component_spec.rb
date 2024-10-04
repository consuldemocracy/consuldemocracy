require "rails_helper"

describe Admin::Projects::ShowComponent, controller: Admin::ProjectsController do

  describe "show project" do
    it "list project with no phases" do
      project = create(:project, title: "A project")
      project.update(state: 'draft')

      render_inline Admin::Projects::ShowComponent.new(project)

      expect(page).to have_content "No phases for this project created yet."
    end
    it "list project with phases" do
      project = create(:project, title: "A project")
      phase1 = create(:project_phase, project: project, title_short: "First phase")
      phase2 = create(:project_phase, project: project, title_short: "Second phase")
      phase1.update(enabled: true, order: 1)
      phase2.update(enabled: true, order: 2)
      render_inline Admin::Projects::ShowComponent.new(project)

      expect(page).to have_no_content "No phases for this project created yet."
      expect(page).to have_content "First phase"
      expect(page.find("tr:last-child", text: "Second phase")).to have_content "2"
    end

    it "list project with phases sorted by order" do
      project = create(:project, title: "A project")
      phase1 = create(:project_phase, project: project, title_short: "First phase")
      phase2 = create(:project_phase, project: project, title_short: "Second phase")
      phase1.update(enabled: true, order: 15)
      phase2.update(enabled: true, order: 2)

      render_inline Admin::Projects::ShowComponent.new(project)
      expect(page.find("tr:last-child", text: "First phase")).to have_content "15"
    end
  end

end
