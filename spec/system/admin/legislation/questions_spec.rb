require "rails_helper"

describe "Admin legislation questions", :admin do
  let!(:process) { create(:legislation_process, title: "An example legislation process") }

  context "Feature flag" do
    before do
      Setting["process.legislation"] = nil
    end

    scenario "Disabled with a feature flag" do
      expect { visit admin_legislation_process_questions_path(process) }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  context "Index" do
    scenario "Displaying legislation process questions" do
      create(:legislation_question, process: process, title: "Question 1")
      create(:legislation_question, process: process, title: "Question 2")

      visit admin_legislation_processes_path(filter: "all")

      within("tr", text: "An example legislation process") { click_link "Edit" }
      click_link "Debate"

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Question 2")
    end
  end

  context "Create" do
    scenario "Valid legislation question" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Collaborative Legislation"
      end

      click_link "All"

      within("tr", text: "An example legislation process") { click_link "Edit" }
      click_link "Debate"

      click_link "Create question"

      fill_in "Question", with: "Question 3"
      click_button "Create question"

      expect(page).to have_content "Question 3"
    end
  end

  context "Update" do
    scenario "Valid legislation question", :js do
      create(:legislation_question, title: "Question 2", process: process)

      visit admin_root_path

      within("#side_menu") do
        click_link "Collaborative Legislation"
      end

      click_link "All"

      expect(page).not_to have_link "All"

      within("tr", text: "An example legislation process") { click_link "Edit" }
      click_link "Debate"
      click_link "Question 2"

      fill_in "Question", with: "Question 2b"
      click_button "Save changes"

      expect(page).to have_content "Question 2b"
    end
  end

  context "Delete" do
    scenario "Legislation question", :js do
      create(:legislation_question, title: "Question 1", process: process)
      question = create(:legislation_question, title: "Question 2", process: process)
      question_option = create(:legislation_question_option, question: question, value: "Yes")
      create(:legislation_answer, question: question, question_option: question_option)

      visit edit_admin_legislation_process_question_path(process, question)

      click_link "Delete"

      expect(page).to have_content "Questions"
      expect(page).to have_content "Question 1"
      expect(page).not_to have_content "Question 2"
    end
  end

  context "Legislation options" do
    let!(:question) { create(:legislation_question) }

    let(:edit_question_url) do
      edit_admin_legislation_process_question_path(question.process, question)
    end

    let(:field_en) { fields_for(:en).first }
    let(:field_es) { fields_for(:es).first }

    def fields_for(locale)
      within("#nested_question_options") do
        page.all(
          "[data-locale='#{locale}'] [id^='legislation_question_question_option'][id$='value']"
        )
      end
    end

    scenario "Edit an existing option", :js do
      create(:legislation_question_option, question: question, value: "Original")

      visit edit_question_url
      find("#nested_question_options input").set("Changed")
      click_button "Save changes"

      expect(page).not_to have_css "#error_explanation"

      visit edit_question_url
      expect(page).to have_field(field_en[:id], with: "Changed")
    end

    scenario "Remove an option", :js do
      create(:legislation_question_option, question: question, value: "Yes")
      create(:legislation_question_option, question: question, value: "No")

      visit edit_question_url

      expect(page).to have_field fields_for(:en).first[:id], with: "Yes"
      expect(page).to have_field fields_for(:en).last[:id], with: "No"

      page.first(:link, "Remove option").click

      expect(page).not_to have_field fields_for(:en).first[:id], with: "Yes"
      expect(page).to have_field fields_for(:en).last[:id], with: "No"

      click_button "Save changes"
      visit edit_question_url

      expect(page).not_to have_field fields_for(:en).first[:id], with: "Yes"
      expect(page).to have_field fields_for(:en).last[:id], with: "No"
    end

    context "Special translation behaviour" do
      before do
        question.update!(title_en: "Title in English", title_es: "Título en Español")
      end

      scenario "Add translation for question option", :js do
        visit edit_question_url

        click_on "Add option"

        find("#nested_question_options input").set("Option 1")

        select "Español", from: :select_language

        find("#nested_question_options input").set("Opción 1")

        click_button "Save changes"
        visit edit_question_url

        expect(page).to have_field(field_en[:id], with: "Option 1")

        select "Español", from: :select_language

        expect(page).to have_field(field_es[:id], with: "Opción 1")
      end

      scenario "Add new question option after changing active locale", :js do
        visit edit_question_url

        select "Español", from: :select_language

        click_on "Add option"

        find("#nested_question_options input").set("Opción 1")

        select "English", from: :select_language

        find("#nested_question_options input").set("Option 1")

        click_button "Save changes"

        visit edit_question_url

        expect(page).to have_field(field_en[:id], with: "Option 1")

        select "Español", from: :select_language

        expect(page).to have_field(field_es[:id], with: "Opción 1")
      end
    end
  end
end
