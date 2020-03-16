require "rails_helper"

describe "budget tasks" do
  describe "set_published" do
    let(:run_rake_task) do
      Rake::Task["budgets:set_published"].reenable
      Rake.application.invoke_task("budgets:set_published")
    end

    it "does not change anything if the published attribute is set" do
      budget = create(:budget, published: false, phase: "accepting")

      run_rake_task
      budget.reload

      expect(budget.phase).to eq "accepting"
      expect(budget.published).to be false
    end

    it "publishes budgets which are not in draft mode" do
      budget = create(:budget, published: nil, phase: "accepting")

      run_rake_task
      budget.reload

      expect(budget.phase).to eq "accepting"
      expect(budget.published).to be true
    end

    it "changes the published attribute to false on drafting budgets" do
      stub_const("Budget::Phase::PHASE_KINDS", ["drafting"] + Budget::Phase::PHASE_KINDS)
      budget = create(:budget, published: nil)
      budget.update_column(:phase, "drafting")
      stub_const("Budget::Phase::PHASE_KINDS", Budget::Phase::PHASE_KINDS - ["drafting"])

      run_rake_task
      budget.reload

      expect(budget.published).to be false
      expect(budget.phase).to eq "informing"
    end

    it "changes the phase to the first enabled phase" do
      budget = create(:budget, published: nil)
      budget.update_column(:phase, "drafting")
      budget.phases.informing.update!(enabled: false)

      expect(budget.phase).to eq "drafting"

      run_rake_task
      budget.reload

      expect(budget.phase).to eq "accepting"
      expect(budget.published).to be false
    end

    it "enables and select the informing phase if there are not any enabled phases" do
      budget = create(:budget, published: nil)
      budget.update_column(:phase, "drafting")
      budget.phases.each { |phase| phase.update!(enabled: false) }

      expect(budget.phase).to eq "drafting"

      run_rake_task
      budget.reload

      expect(budget.phase).to eq "informing"
      expect(budget.phases.informing.enabled).to be true
      expect(budget.published).to be false
    end
  end

  describe "phases_summary_to_description" do
    let(:run_rake_task) do
      Rake::Task["budgets:phases_summary_to_description"].reenable
      Rake.application.invoke_task("budgets:phases_summary_to_description")
    end

    it "appends the content of summary to the content of description" do
      budget = create(:budget)
      budget_phase = budget.phases.informing
      budget_phase.update!(
        description_en: "English description",
        description_es: "Spanish description",
        description_fr: "French description",
        summary_en: "English summary",
        summary_fr: "French summary"
      )

      run_rake_task

      budget_phase.reload
      expect(budget_phase.description_en).to eq "English description<br>English summary"
      expect(budget_phase.description_es).to eq "Spanish description"
      expect(budget_phase.description_fr).to eq "French description<br>French summary"
      expect(budget_phase.summary).to be nil
    end
  end
end
