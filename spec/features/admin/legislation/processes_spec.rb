require "rails_helper"

feature "Admin legislation processes" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "translatable",
                  "legislation_process",
                  "edit_admin_legislation_process_path",
                  %w[title summary description additional_info]

  it_behaves_like "admin_milestoneable",
                  :legislation_process,
                  "admin_legislation_process_milestones_path"

  context "Feature flag" do

    scenario "Disabled with a feature flag" do
      Setting["feature.legislation"] = nil
      expect{ visit admin_legislation_processes_path }
      .to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario "Displaying legislation processes" do
      process = create(:legislation_process)
      visit admin_legislation_processes_path(filter: "all")

      expect(page).to have_content(process.title)
    end

    scenario "Processes are sorted by descending start date" do
      create(:legislation_process, title: "Process 1", start_date: Date.yesterday)
      create(:legislation_process, title: "Process 2", start_date: Date.today)
      create(:legislation_process, title: "Process 3", start_date: Date.tomorrow)

      visit admin_legislation_processes_path(filter: "all")

      expect("Process 3").to appear_before("Process 2")
      expect("Process 2").to appear_before("Process 1")
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
               with: (base_date - 1.days).strftime("%d/%m/%Y")
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
      visit new_admin_legislation_process_path()
      fill_in "Process Title", with: "An example legislation process"
      fill_in "Summary", with: "Summary of the process"

      base_date = Date.current
      fill_in "legislation_process[start_date]", with: base_date.strftime("%d/%m/%Y")
      fill_in "legislation_process[end_date]", with: (base_date + 5.days).strftime("%d/%m/%Y")
      imageable_attach_new_file(create(:image), Rails.root.join("spec/fixtures/files/clippy.jpg"))

      click_button "Create process"

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Process created successfully"

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_css("img[alt='#{Legislation::Process.last.title}']")
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

      click_link "An example legislation process"

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

      click_link "An example legislation process"

      expect(find("#legislation_process_draft_publication_enabled")).to be_checked

      uncheck "legislation_process_draft_publication_enabled"
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"
      expect(find("#debate_start_date").value).not_to be_blank
      expect(find("#debate_end_date").value).not_to be_blank

      click_link "Click to visit"

      expect(page).not_to have_content "Draft publication"
    end

    scenario "Change proposal categories" do
      visit edit_admin_legislation_process_path(process)
      within(".admin-content") { click_link "Proposals" }

      fill_in "Categories", with: "recycling,bicycles"
      click_button "Save changes"

      visit admin_legislation_process_proposals_path(process)
      expect(page).to have_field("Categories", with: "bicycles, recycling")
    end

    scenario "Edit milestones summary", :js do
      visit admin_legislation_process_milestones_path(process)

      expect(page).not_to have_link "Remove language"
      expect(page).not_to have_field "translation_locale"

      within(".translatable-fields[data-locale='en']") do
        fill_in_ckeditor find("textarea", visible: false)[:id],
                         with: "There is still a long journey ahead of us"
      end

      click_button "Update Process"

      expect(page).to have_current_path admin_legislation_process_milestones_path(process)

      visit milestones_legislation_process_path(process)

      expect(page).to have_content "There is still a long journey ahead of us"
    end
  end
end
