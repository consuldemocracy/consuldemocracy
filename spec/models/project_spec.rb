require "rails_helper"

describe Project do
  let(:project) { create(:project) }

  it_behaves_like "globalizable", :project
  # it_behaves_like "acts as imageable", :budget_image

  describe "scopes" do
    describe ".active" do
      it "returns all projects in state=active" do
        active = create(:project)
        active.update(state: 'active')

        expect(Project.active).to eq [active]
      end

      it "does not return projects in other states" do
        draft = create(:project)
        draft.update(state: 'draft')
        archived = create(:project)
        archived.update(state: 'archived')

        expect(Project.active).to be_empty
      end
    end

    describe ".archived" do
      it "returns all projects in state=archived" do
        archived = create(:project)
        archived.update(state: 'archived')

        expect(Project.archived).to eq [archived]
      end

      it "does not return projects in other states" do
        draft = create(:project)
        draft.update(state: 'draft')
        active = create(:project)
        active.update(state: 'active')

        expect(Project.archived).to be_empty
      end
    end

    describe ".published" do
      it "returns all publicly visible projects state!=draft" do
        archived = create(:project)
        archived.update(state: 'archived')
        active = create(:project)
        active.update(state: 'active')

        expect(Project.published).to match_array([archived, active])
      end
      
      it "does not return draft projects" do
        draft = create(:project)
        draft.update(state: 'draft')

        expect(Project.published).to be_empty
      end
    end
  end

  describe "next phase order" do
    it "gives 1 when no phases" do
      project.phases.destroy_all

      expect(project.next_phase_order()).to eq 1
    end

    it "gives last phase + 1" do
      phase1 = create(:project_phase, project: project, title_short: "First phase")
      phase2 = create(:project_phase, project: project, title_short: "Second phase")
      phase1.update(enabled: true, order: 15)
      phase2.update(enabled: true, order: 2)

      expect(project.next_phase_order()).to eq 16
    end
  end

end
