require "rails_helper"

describe Projects::IndexComponent, controller: ProjectsController do
  Setting["process.projects"] = true

  describe "#phase" do
    let(:project) { create(:project, title: "ShowProject") }

    it "show project homepage" do
      render_inline Projects::ShowComponent.new(project, nil)

      expect(page).to have_content "ShowProject"
      expect(page).to have_content project.content
    end

    it "show phase" do
      active_phase = create(:project_phase, project: project, title_short: "Active Phase")
      render_inline Projects::ShowComponent.new(project, active_phase)

      expect(page).to have_content "ShowProject"
      expect(page).to have_content "Active Phase"
      expect(page).to have_content active_phase.content
    end
  end

  describe "ordered phases" do
    let(:project) { create(:project, title: "ShowProjectOrders") }

    it "phases default order" do
      phase1 = create(:project_phase, project: project, title_short: "First phase")
      phase2 = create(:project_phase, project: project, title_short: "Second phase")
      phase1.update(enabled: true, order: 1)
      phase2.update(enabled: true, order: 2)

      render_inline Projects::ShowComponent.new(project, nil)

      expect(page).to have_content "Homepage"
      expect(page).to have_content "First phase"
      expect(page).to have_content "Second phase"
      expect(page.find("li:last-child", text: "Second phase")).to have_content "Second phase"
    end

    it "phases sorted by custom order" do
      phase1 = create(:project_phase, project: project, title_short: "First phase")
      phase2 = create(:project_phase, project: project, title_short: "Second phase")
      phase1.update(enabled: true, order: 15)
      phase2.update(enabled: true, order: 2)

      render_inline Projects::ShowComponent.new(project, nil)

      expect(page.find("li:last-child", text: "First phase")).to have_content "First phase"
    end
  end

  describe "enabled phases" do
    let(:project) { create(:project, title: "ShowProjectEnabled") }

    it "show enabled phases" do
      phase1 = create(:project_phase, project: project, title_short: "Enabled phase")
      phase1.update(enabled: true)

      render_inline Projects::ShowComponent.new(project, nil)

      expect(page).to have_content "Enabled phase"
    end

    it "don't show disabled phase" do
      phase1 = create(:project_phase, project: project, title_short: "Disabled phase")
      phase1.update(enabled: false)

      render_inline Projects::ShowComponent.new(project, nil)

      expect(page).to have_no_content "Disabled phase"
    end
  end
end