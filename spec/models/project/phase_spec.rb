require "rails_helper"

describe Project do
  let(:project) { create(:project) }

  it_behaves_like "globalizable", :project_phase

  describe "scopes" do
    describe ".enabled" do
      it "returns all phases enabled=true" do
	     project_phase = create(:project_phase, project: project, title_short: "First phase")
        project_phase.update(enabled: true)

        expect(Project::Phase.enabled).to eq [project_phase]
      end

      it "does not return phases enabled=false" do
	    project_phase = create(:project_phase, project: project, title_short: "First phase")
        project_phase.update(enabled: false)

        expect(Project::Phase.enabled).to be_empty
      end
    end

    describe ".sort_by_order" do
      it "returns phases sorted by order" do
        phase1 = create(:project_phase, project: project, title_short: "First phase")
        phase2 = create(:project_phase, project: project, title_short: "Second phase")
        
        expect(Project::Phase.sort_by_order).to match_array([phase1, phase2])

        phase1.update(enabled: true, order: 15)
        phase2.update(enabled: true, order: 2)

        expect(Project::Phase.sort_by_order).to match_array([phase2, phase1])
      end
    end

  end


end
