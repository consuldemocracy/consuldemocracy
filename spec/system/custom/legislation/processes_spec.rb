require "rails_helper"

describe "Legislation" do
  context "processes home page" do
    scenario "Participation phases are displayed only if there is a phase enabled" do
      process = create(:legislation_process, :empty)
      process_debate = create(:legislation_process)

      visit legislation_process_path(process)

      expect(page).not_to have_content("PARTICIPATION PHASES")

      visit legislation_process_path(process_debate)

      expect(page).to have_content("PARTICIPATION PHASES")
    end

    scenario "Participation phases are displayed on current locale" do
      process = create(:legislation_process, proposals_phase_start_date: Date.new(2018, 01, 01),
                                             proposals_phase_end_date: Date.new(2018, 12, 01))

      visit legislation_process_path(process)

      expect(page).to have_content("PARTICIPATION PHASES")
      expect(page).to have_content("Proposals")
      expect(page).to have_content("01 Jan 2018 - 01 Dec 2018")

      visit legislation_process_path(process, locale: "es")

      expect(page).to have_content("FASES DE PARTICIPACIÓN")
      expect(page).to have_content("Propuestas")
      expect(page).to have_content("01 ene 2018 - 01 dic 2018")
    end

    scenario "Participation phases show their status" do
      travel_to "01/06/2020".to_date do
        process = create(:legislation_process, debate_start_date: "01/05/2020",
                         debate_end_date: "30/05/2020",
                         proposals_phase_start_date: "01/06/2020",
                         proposals_phase_end_date: "30/06/2020",
                         draft_publication_date: "20/05/2020",
                         allegations_start_date: "01/06/2020",
                         allegations_end_date: "05/06/2020",
                         result_publication_date: "01/07/2020")

        visit legislation_processes_path

        within("#legislation_process_#{process.id} .legislation-calendar") do
          expect(page).to have_content ["Debate (0)", "01 May 2020 - 30 May 2020", "LOCKED"].join("\n")
          expect(page).to have_content ["Draft publication", "20 May 2020", "PUBLISHED"].join("\n")
          expect(page).to have_content ["Proposals (0)", "01 Jun 2020 - 30 Jun 2020", "ACTIVE"].join("\n")
          expect(page).to have_content ["Comments (0)", "01 Jun 2020 - 05 Jun 2020", "ACTIVE"].join("\n")
          expect(page).to have_content ["Final result publication", "01 Jul 2020", "COMING SOON"].join("\n")
        end

        visit legislation_process_path(process)

        within(".legislation-content") do
          expect(page).to have_content ["DRAFT PUBLICATION", "20 May 2020"].join("\n")
          expect(page).to have_content ["FINAL RESULT PUBLICATION", "01 Jul 2020"].join("\n")
        end

        within(".legislation-process-list") do
          expect(page).to have_content ["Debate (0)", "01 May 2020 - 30 May 2020", "LOCKED"].join("\n")
          expect(page).to have_content ["Proposals (0)", "01 Jun 2020 - 30 Jun 2020", "ACTIVE"].join("\n")
          expect(page).to have_content ["Comments (0)", "01 Jun 2020 - 05 Jun 2020", "ACTIVE"].join("\n")
        end

        create(:legislation_question, process: process)
        create(:legislation_question, process: process)
        create(:legislation_proposal, legislation_process_id: process.id)
        create(:legislation_proposal, legislation_process_id: process.id)
        draft_version = create(:legislation_draft_version, :published, process: process)
        create(:legislation_annotation, draft_version: draft_version)
        create(:legislation_annotation, draft_version: draft_version)

        visit legislation_processes_path

        within("#legislation_process_#{process.id} .legislation-calendar") do
          expect(page).to have_content ["Debate (2)", "01 May 2020 - 30 May 2020", "LOCKED"].join("\n")
          expect(page).to have_content ["Proposals (2)", "01 Jun 2020 - 30 Jun 2020", "ACTIVE"].join("\n")
          expect(page).to have_content ["Comments (2)", "01 Jun 2020 - 05 Jun 2020", "ACTIVE"].join("\n")
        end

        visit legislation_process_path(process)

        within(".legislation-process-list") do
          expect(page).to have_content ["Debate (2)", "01 May 2020 - 30 May 2020", "LOCKED"].join("\n")
          expect(page).to have_content ["Proposals (2)", "01 Jun 2020 - 30 Jun 2020", "ACTIVE"].join("\n")
          expect(page).to have_content ["Comments (2)", "01 Jun 2020 - 05 Jun 2020", "ACTIVE"].join("\n")
        end
      end
    end

    scenario "Participation phases have a link to the corresponding phase" do
      travel_to "01/06/2020".to_date
      process = create(:legislation_process, debate_start_date: "01/05/2020",
                       debate_end_date: "30/05/2020",
                       proposals_phase_start_date: "01/06/2020",
                       proposals_phase_end_date: "30/06/2020",
                       draft_publication_date: "20/05/2020",
                       allegations_start_date: "01/06/2020",
                       allegations_end_date: "05/06/2020",
                       result_publication_date: "01/07/2020")

      phase_debate = ["Debate (0)", "01 May 2020 - 30 May 2020", "LOCKED"].join("\n")
      phase_draft = ["Draft publication", "20 May 2020", "PUBLISHED"].join("\n")
      phase_proposals = ["Proposals (0)", "01 Jun 2020 - 30 Jun 2020", "ACTIVE"].join("\n")
      phase_comments = ["Comments (0)", "01 Jun 2020 - 05 Jun 2020", "ACTIVE"].join("\n")
      phase_result = ["Final result publication", "01 Jul 2020", "COMING SOON"].join("\n")

      visit legislation_processes_path

      within("#legislation_process_#{process.id} .legislation-calendar") do
        expect(page).to have_selector("a", text: phase_debate)
        expect(page).to have_selector("a", text: phase_draft)
        expect(page).to have_selector("a", text: phase_proposals)
        expect(page).to have_selector("a", text: phase_comments)
        expect(page).to have_selector("a", text: phase_result)
        expect(page).to have_link(href: debate_legislation_process_path(process))
        expect(page).to have_link(href: draft_publication_legislation_process_path(process))
        expect(page).to have_link(href: proposals_legislation_process_path(process))
        expect(page).to have_link(href: allegations_legislation_process_path(process))
        expect(page).to have_link(href: result_publication_legislation_process_path(process))
      end

      travel_back
    end

    scenario "Show SDG tags when feature is enabled" do
      Setting["feature.sdg"] = true
      Setting["sdg.process.legislation"] = true

      process = create(:legislation_process, sdg_goals: [SDG::Goal[1]],
                                   sdg_targets: [SDG::Target["1.1"]])

      visit legislation_process_path(process)

      expect(page).to have_selector "img[alt='1. No Poverty']"
      expect(page).to have_content "target 1.1"
    end
  end

  context "process page" do
    context "show" do
      scenario "do not show additional info button if it is empty" do
        process = create(:legislation_process)

        visit legislation_process_path(process)

        expect(page).not_to have_button "Additional information"
        expect(page).not_to have_button "Less information"
      end
    end
  end
end
