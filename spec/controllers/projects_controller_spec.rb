require "rails_helper"

describe ProjectsController do

  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.projects"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "success when enabled" do
      Setting["process.projects"] = true
      get :index
      expect(response).to be_successful
    end

    it "success when filter=archived" do
      Setting["process.projects"] = true
      get :index, params: {filter: 'archived'}
      expect(response).to be_successful
    end

    it "success when filter=active" do
      Setting["process.projects"] = true
      get :index, params: {filter: 'active'}
      expect(response).to be_successful
    end
  end

  describe "GET show" do
    it "not_found when project does not exist" do
      Setting["process.projects"] = true
      expect do
        get :show, params: { id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "not_found when project is in draft state" do
      Setting["process.projects"] = true
      project = create(:project, title: "A project")
      project.update(state: 'draft')

      expect do
        get :show, params: { id: project }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "success when project is active" do
      Setting["process.projects"] = true
      project = create(:project, title: "A project")
      project.update(state: 'active')

      get :show, params: { id: project }

      expect(response).to be_successful
    end

    it "success when project is archived" do
      Setting["process.projects"] = true
      project = create(:project, title: "A project")
      project.update(state: 'archived')

      get :show, params: { id: project }

      expect(response).to be_successful
    end

    it "#phase param, success when enabled" do
      Setting["process.projects"] = true
      project = create(:project, title: "A project")
      project.update(state: 'active')
      phase = create(:project_phase, project: project, title_short: "MyPhase")
      phase.update(enabled: true)

      get :show, params: { id: project, phase: phase }

      expect(response).to be_successful
    end

    it "#phase param, not_found when disabled" do
      Setting["process.projects"] = true
      project = create(:project, title: "A project")
      project.update(state: 'active')
      phase = create(:project_phase, project: project, title_short: "MyPhase")
      phase.update(enabled: false)

      expect do
        get :show, params: { id: project, phase: phase }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end