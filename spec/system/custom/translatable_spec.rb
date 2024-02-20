require "rails_helper"

describe "Public area translatable records" do
  let(:user) { create(:user, :in_census) }

  before do
    Setting["feature.translation_interface"] = true
    login_as(user)
  end

  context "New records" do
    scenario "Add only single translation at once" do
      visit new_debate_path

      fill_in_new_debate_title with: "Who won the debate?"
      fill_in_ckeditor "Initial debate text", with: "And who will win this debate?"
      click_button "Start a debate"

      expect(page).to have_content "Debate created successfully"
    end

    scenario "Add single translation maintains introduced field values" do
      visit new_proposal_path

      fill_in_new_proposal_title with: "Olympic Games in Melbourne"
      fill_in "Proposal summary", with: "Full proposal for our candidature"
      fill_in_ckeditor "Proposal text", with: "2032 will make Australia famous again"
      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully"
      expect(page).to have_content "Olympic Games in Melbourne"
      expect(page).to have_content "Full proposal for our candidature"
      expect(page).to have_content "2032 will make Australia famous again"
    end

    scenario "Add multiple translations at once" do
      budget = create(:budget_heading, name: "Everywhere").group.budget

      visit new_budget_investment_path(budget)

      fill_in_new_investment_title with: "My awesome project"
      fill_in_ckeditor "Description", with: "Everything is awesome!"

      select "Français", from: :add_language
      fill_in_new_investment_title with: "Titre en Français"
      fill_in_ckeditor "Description", with: "Contenu en Français"

      click_button "Create Investment"

      expect(page).to have_content "Budget Investment created successfully"
    end

    scenario "Add only single translation at once not having the current locale" do
      visit new_proposal_path
      click_link "Remove language"
      select "Français", from: :add_language

      fill_in_new_proposal_title with: "Titre en Français"
      fill_in "Proposal summary", with: "Résumé en Français"
      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully"
    end

    scenario "Add a translation for a locale with non-underscored name" do
      budget = create(:budget_heading, name: "Everywhere").group.budget

      visit new_budget_investment_path(budget)
      click_link "Remove language"
      select "Português brasileiro", from: :add_language
      fill_in_new_investment_title with: "Titre en Français"
      fill_in_ckeditor "Description", with: "Contenu en Français"

      click_button "Create Investment"

      expect(page).to have_content "Budget Investment created successfully"
    end

    scenario "Add an invalid translation" do
      visit new_debate_path

      click_button "Start a debate"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_field "Debate title", with: "", class: "is-invalid-input"
    end

    scenario "Shows errors when submiting without any active translations" do
      budget = create(:budget_heading, name: "Everywhere").group.budget

      visit new_budget_investment_path(budget)
      click_link "Remove language"

      click_button "Create Investment"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_field "Title", with: ""
    end
  end
end
