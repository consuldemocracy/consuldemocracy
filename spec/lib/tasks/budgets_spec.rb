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
        name_es: "Spanish name",
        name_fr: "French name",
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

  describe "add_name_to_existing_phases" do
    let(:run_rake_task) do
      Rake::Task["budgets:add_name_to_existing_phases"].reenable
      Rake.application.invoke_task("budgets:add_name_to_existing_phases")
    end

    it "adds the name to existing budget phases" do
      budget = create(:budget)
      informing_phase = budget.phases.informing
      accepting_phase = budget.phases.accepting

      accepting_phase.update!(name_en: "Custom accepting", name_es: "Aceptando personalizado")
      informing_phase.translations.create!(locale: :es, name: "temp")
      informing_phase.translations.update_all(name: "")

      expect(informing_phase.name_en).to eq ""
      expect(informing_phase.name_es).to eq ""
      expect(informing_phase.name_fr).to be nil
      expect(accepting_phase.name_en).to eq "Custom accepting"
      expect(accepting_phase.name_es).to eq "Aceptando personalizado"
      expect(accepting_phase.name_fr).to be nil

      run_rake_task

      expect(informing_phase.reload.name_en).to eq "Information"
      expect(informing_phase.reload.name_es).to eq "Información"
      expect(informing_phase.reload.name_fr).to be nil
      expect(accepting_phase.reload.name_en).to eq "Custom accepting"
      expect(accepting_phase.reload.name_es).to eq "Aceptando personalizado"
      expect(accepting_phase.reload.name_fr).to be nil
    end

    it "adds the name in default locale to existing translations no longer available" do
      budget = create(:budget)
      informing_phase = budget.phases.informing
      obsolete_translation = informing_phase.translations.build(locale: :fiction)
      obsolete_translation.save!(validate: false)

      expect(obsolete_translation.reload.name).to be nil

      run_rake_task

      expect(obsolete_translation.reload.name).to eq "Information"
    end

    it "adds a default translation to phases with no translations" do
      budget = create(:budget)
      informing_phase = budget.phases.informing
      informing_phase.translations.destroy_all

      expect(informing_phase.reload.name).to be nil

      run_rake_task

      expect(informing_phase.reload.name).to eq "Information"
    end
  end
end
