require "rails_helper"

describe "Admin collaborative legislation", :admin do
  it_behaves_like "admin_milestoneable",
                  :legislation_process,
                  "admin_legislation_process_milestones_path"

  context "Feature flag" do
    scenario "Disabled with a feature flag" do
      Setting["process.legislation"] = nil
      expect { visit admin_legislation_processes_path }
      .to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  context "Index" do
    scenario "Displaying collaborative legislation" do
      process_1 = create(:legislation_process, title: "Process open")
      process_2 = create(:legislation_process, title: "Process for the future",
                                               start_date: Date.current + 5.days)
      process_3 = create(:legislation_process, title: "Process closed",
                                               start_date: Date.current - 10.days,
                                               end_date: Date.current - 6.days)

      visit admin_legislation_processes_path(filter: "active")

      expect(page).to have_content(process_1.title)
      expect(page).to have_content(process_2.title)
      expect(page).not_to have_content(process_3.title)

      visit admin_legislation_processes_path(filter: "all")

      expect(page).to have_content(process_1.title)
      expect(page).to have_content(process_2.title)
      expect(page).to have_content(process_3.title)
    end

    scenario "Processes are sorted by descending start date" do
      process_1 = create(:legislation_process, title: "Process 1", start_date: Date.yesterday)
      process_2 = create(:legislation_process, title: "Process 2", start_date: Date.current)
      process_3 = create(:legislation_process, title: "Process 3", start_date: Date.tomorrow)

      visit admin_legislation_processes_path(filter: "all")

      expect(page).to have_content process_1.start_date
      expect(page).to have_content process_2.start_date
      expect(page).to have_content process_3.start_date

      expect(page).to have_content process_1.end_date
      expect(page).to have_content process_2.end_date
      expect(page).to have_content process_3.end_date

      expect(process_3.title).to appear_before(process_2.title)
      expect(process_2.title).to appear_before(process_1.title)
    end
  end

  context "Create" do
    scenario "Valid legislation process" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Collaborative Legislation"
      end

      expect(page).not_to have_content "An example legislation process"

      click_link "New process"

      fill_in "Process Title", with: "An example legislation process"
      fill_in "Summary", with: "Summary of the process"
      fill_in "Description", with: "Describing the process"

      base_date = Date.current
      fill_in "legislation_process[start_date]", with: base_date.strftime("%d/%m/%Y")
      fill_in "legislation_process[end_date]", with: (base_date + 5.days).strftime("%d/%m/%Y")

      fill_in "legislation_process[debate_start_date]",
               with: base_date.strftime("%d/%m/%Y")
      fill_in "legislation_process[debate_end_date]",
               with: (base_date + 2.days).strftime("%d/%m/%Y")
      fill_in "legislation_process[draft_start_date]",
               with: (base_date - 3.days).strftime("%d/%m/%Y")
      fill_in "legislation_process[draft_end_date]",
               with: (base_date - 1.day).strftime("%d/%m/%Y")
      fill_in "legislation_process[draft_publication_date]",
               with: (base_date + 3.days).strftime("%d/%m/%Y")
      fill_in "legislation_process[allegations_start_date]",
               with: (base_date + 3.days).strftime("%d/%m/%Y")
      fill_in "legislation_process[allegations_end_date]",
               with: (base_date + 5.days).strftime("%d/%m/%Y")
      fill_in "legislation_process[result_publication_date]",
               with: (base_date + 7.days).strftime("%d/%m/%Y")

      click_button "Create process"

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Process created successfully"

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_content "Describing the process"

      visit legislation_processes_path

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Summary of the process"
      expect(page).not_to have_content "Describing the process"
    end

    scenario "Legislation process in draft phase" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Collaborative Legislation"
      end

      expect(page).not_to have_content "An example legislation process"

      click_link "New process"

      fill_in "Process Title", with: "An example legislation process in draft phase"
      fill_in "Summary", with: "Summary of the process"
      fill_in "Description", with: "Describing the process"

      base_date = Date.current - 2.days
      fill_in "legislation_process[start_date]", with: base_date.strftime("%d/%m/%Y")
      fill_in "legislation_process[end_date]", with: (base_date + 5.days).strftime("%d/%m/%Y")

      fill_in "legislation_process[draft_start_date]", with: base_date.strftime("%d/%m/%Y")
      fill_in "legislation_process[draft_end_date]", with: (base_date + 3.days).strftime("%d/%m/%Y")
      check "legislation_process[draft_phase_enabled]"

      click_button "Create process"

      expect(page).to have_content "An example legislation process in draft phase"
      expect(page).to have_content "Process created successfully"

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process in draft phase"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_content "Describing the process"

      visit legislation_processes_path

      expect(page).not_to have_content "An example legislation process in draft phase"
      expect(page).not_to have_content "Summary of the process"
      expect(page).not_to have_content "Describing the process"
    end

    scenario "Create a legislation process with an image", :js do
      visit new_admin_legislation_process_path
      fill_in "Process Title", with: "An example legislation process"
      fill_in "Summary", with: "Summary of the process"

      base_date = Date.current
      fill_in "legislation_process[start_date]", with: base_date
      fill_in "legislation_process[end_date]", with: base_date + 5.days
      imageable_attach_new_file(create(:image), Rails.root.join("spec/fixtures/files/clippy.jpg"))

      click_button "Create process"

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Process created successfully"

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_css("img[alt='#{Legislation::Process.last.title}']")
    end

    scenario "Default colors are present" do
      visit new_admin_legislation_process_path

      expect(find("#legislation_process_background_color").value).to eq "#e7f2fc"
      expect(find("#legislation_process_font_color").value).to eq "#222222"
    end
  end

  context "Update" do
    let!(:process) do
      create(:legislation_process,
             title: "An example legislation process",
             summary: "Summarizing the process",
             description: "Description of the process")
    end

    scenario "Remove summary text" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Collaborative Legislation"
      end

      within("tr", text: "An example legislation process") { click_link "Edit" }

      expect(page).to have_selector("h2", text: "An example legislation process")
      expect(find("#legislation_process_debate_phase_enabled")).to be_checked
      expect(find("#legislation_process_published")).to be_checked

      fill_in "Summary", with: ""
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"

      visit legislation_processes_path
      expect(page).not_to have_content "Summarizing the process"
      expect(page).to have_content "Description of the process"
    end

    scenario "Deactivate draft publication" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Collaborative Legislation"
      end

      within("tr", text: "An example legislation process") { click_link "Edit" }

      expect(find("#legislation_process_draft_publication_enabled")).to be_checked

      uncheck "legislation_process_draft_publication_enabled"
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"
      expect(find("#debate_start_date").value).not_to be_blank
      expect(find("#debate_end_date").value).not_to be_blank

      click_link "Click to visit"

      expect(page).not_to have_content "Draft publication"
    end

    scenario "Enabling/disabling a phase enables/disables its date fields", :js do
      process.update!(published: false)

      visit edit_admin_legislation_process_path(process)

      expect(page).to have_field "start_date", disabled: true
      expect(page).to have_field "end_date", disabled: true

      check "legislation_process[published]"
      fill_in "start_date", with: "07/07/2007"
      fill_in "end_date", with: "08/08/2008"
      uncheck "legislation_process[published]"

      expect(page).to have_field "start_date", disabled: true
      expect(page).to have_field "end_date", disabled: true

      check "legislation_process[published]"

      expect(page).to have_field "start_date", disabled: false, with: "2007-07-07"
      expect(page).to have_field "end_date", disabled: false, with: "2008-08-08"
    end

    scenario "Enabling/disabling a phase does not enable/disable another phase date fields", :js do
      process.update!(draft_phase_enabled: false, draft_publication_enabled: false)

      visit edit_admin_legislation_process_path(process)

      expect(page).to have_field "draft_start_date", disabled: true
      expect(page).to have_field "draft_end_date", disabled: true
      expect(page).to have_field "draft_publication_date", disabled: true

      check "legislation_process[draft_phase_enabled]"

      expect(page).to have_field "draft_start_date", disabled: false
      expect(page).to have_field "draft_end_date", disabled: false
      expect(page).to have_field "draft_publication_date", disabled: true
    end

    scenario "Change proposal categories" do
      visit edit_admin_legislation_process_path(process)
      within(".admin-content") { click_link "Proposals" }

      fill_in "Categories", with: "recycling,bicycles,pollution"
      click_button "Save changes"

      visit admin_legislation_process_proposals_path(process)

      expect(page).to have_field("Categories", with: "bicycles, pollution, recycling")

      within(".admin-content") { click_link "Information" }
      fill_in "Summary", with: "Summarizing the process"
      click_button "Save changes"

      visit admin_legislation_process_proposals_path(process)

      expect(page).to have_field("Categories", with: "bicycles, pollution, recycling")
    end

    scenario "Edit milestones summary", :js do
      visit admin_legislation_process_milestones_path(process)

      expect(page).not_to have_link "Remove language"
      expect(page).not_to have_field "translation_locale"

      fill_in_ckeditor "Summary", with: "There is still a long journey ahead of us"

      click_button "Update Process"

      expect(page).to have_current_path admin_legislation_process_milestones_path(process)

      visit milestones_legislation_process_path(process)

      expect(page).to have_content "There is still a long journey ahead of us"
    end
  end

  context "Special interface translation behaviour" do
    let!(:process) { create(:legislation_process) }

    before { Setting["feature.translation_interface"] = true }

    scenario "Cant manage translations on homepage form" do
      visit edit_admin_legislation_process_homepage_path(process)

      expect(page).not_to have_css "#add_language"
      expect(page).not_to have_link "Remove language"
    end

    scenario "Cant manage translations on milestones summary form" do
      visit admin_legislation_process_milestones_path(process)

      expect(page).not_to have_css "#add_language"
      expect(page).not_to have_link "Remove language"
    end
  end

  context "SDG related list" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.legislation"] = true
    end

    scenario "create Collaborative Legislation with sdg related list", :js do
      visit new_admin_legislation_process_path
      fill_in "Process Title", with: "Legislation process with SDG related content"
      within_fieldset "Process" do
        fill_in "Start", with: 2.days.ago
        fill_in "End", with: 1.day.from_now
      end

      click_sdg_goal(17)
      click_button "Create process"
      visit admin_legislation_processes_path

      within("tr", text: "Legislation process with SDG related content") do
        expect(page).to have_css "td", exact_text: "17"
      end
    end

    scenario "edit Collaborative Legislation with sdg related list", :js do
      process = create(:legislation_process, title: "Legislation process with SDG related content")
      process.sdg_goals = [SDG::Goal[1], SDG::Goal[17]]
      visit edit_admin_legislation_process_path(process)

      remove_sdg_goal_or_target_tag(1)
      click_button "Save changes"
      visit admin_legislation_processes_path

      within("tr", text: "Legislation process with SDG related content") do
        expect(page).to have_css "td", exact_text: "17"
      end
    end
  end
end
