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
      check "debate_terms_of_service"
      click_button "Start a debate"

      expect(page).to have_content "Debate created successfully"
    end

    scenario "Add single translation maintains introduced field values" do
      visit new_proposal_path

      fill_in_new_proposal_title with: "Olympic Games in Melbourne"
      fill_in "Proposal summary", with: "Full proposal for our candidature"
      fill_in_ckeditor "Proposal text", with: "2032 will make Australia famous again"
      check "proposal_terms_of_service"
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

      select "Français", from: "Add language"
      fill_in_new_investment_title with: "Titre en Français"
      fill_in_ckeditor "Description", with: "Contenu en Français"

      check "budget_investment_terms_of_service"
      click_button "Create Investment"

      expect(page).to have_content "Budget Investment created successfully"
    end

    scenario "Add only single translation at once not having the current locale" do
      visit new_proposal_path
      click_link "Remove language"
      select "Français", from: "Add language"

      fill_in_new_proposal_title with: "Titre en Français"
      fill_in "Proposal summary", with: "Résumé en Français"
      check "proposal_terms_of_service"
      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully"
    end

    scenario "Add a translation for a locale with non-underscored name" do
      budget = create(:budget_heading, name: "Everywhere").group.budget

      visit new_budget_investment_path(budget)
      click_link "Remove language"
      select "Português brasileiro", from: "Add language"
      fill_in_new_investment_title with: "Titre en Français"
      fill_in_ckeditor "Description", with: "Contenu en Français"

      check "budget_investment_terms_of_service"
      click_button "Create Investment"

      expect(page).to have_content "Budget Investment created successfully"
    end

    scenario "Add an invalid translation" do
      visit new_debate_path

      check "debate_terms_of_service"
      click_button "Start a debate"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_field "Debate title", with: "", class: "is-invalid-input"
    end

    scenario "Shows errors when submiting without any active translations" do
      budget = create(:budget_heading, name: "Everywhere").group.budget

      visit new_budget_investment_path(budget)
      click_link "Remove language"

      check "budget_investment_terms_of_service"
      click_button "Create Investment"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_field "Title", with: ""
    end
  end

  context "Globalize javascript interface" do
    scenario "Highlight current locale" do
      visit new_debate_path

      expect_to_have_language_selected "English"
    end

    scenario "Highlight new locale added" do
      visit new_proposal_path

      select "Español", from: "Language:"

      expect_to_have_language_selected "Español"
    end

    scenario "Select a locale and add it to the form" do
      visit new_budget_investment_path(create(:budget))

      select "Français", from: "Add language"

      expect(page).to have_field "Title", with: ""
    end

    scenario "Remove a translation" do
      visit new_budget_investment_path(create(:budget))

      expect(find("#select_language").value).to eq "en"
      click_link "Remove language"

      expect_not_to_have_language("English")
    end

    context "Languages in use" do
      scenario "Show default description" do
        visit new_debate_path

        expect(page).to have_content "1 language in use"
      end

      scenario "Increase description count after add new language" do
        visit new_proposal_path

        select "Español", from: "Add language"

        expect(page).to have_content "2 languages in use"
      end

      scenario "Decrease description count after remove a language" do
        visit new_proposal_path

        click_link "Remove language"

        expect(page).to have_content "0 languages in use"
      end
    end

    context "When translation interface feature setting" do
      scenario "Is enabled translation interface should be rendered" do
        visit new_budget_investment_path(create(:budget))

        expect(page).to have_css ".globalize-languages"
      end

      scenario "Is disabled translation interface should not be rendered" do
        Setting["feature.translation_interface"] = nil

        visit new_debate_path

        expect(page).not_to have_css ".globalize-languages"
      end
    end
  end

  context "Existing records" do
    before { translatable.update(attributes.merge(author: user)) }

    let(:attributes) do
      translatable.translated_attribute_names.product(%i[en es]).to_h do |field, locale|
        [:"#{field}_#{locale}", text_for(field, locale)]
      end
    end

    context "Update a translation" do
      context "With valid data" do
        let(:translatable) { create(:debate) }
        let(:path) { edit_debate_path(translatable) }

        scenario "Changes the existing translation" do
          visit path

          select "Español", from: "Current language"

          fill_in "Debate title", with: "Título corregido"
          fill_in_ckeditor "Initial debate text", with: "Texto corregido"

          click_button "Save changes"

          expect(page).to have_content "Debate updated successfully"

          visit path

          expect(page).to have_field "Debate title", with: "Title in English"

          select "Español", from: "Language:"

          expect(page).to have_field "Título del debate", with: "Título corregido"
          expect(page).to have_ckeditor "Texto inicial del debate", with: "Texto corregido"
        end
      end

      context "Update a translation with invalid data" do
        let(:translatable) { create(:proposal) }

        scenario "Show validation errors" do
          visit edit_proposal_path(translatable)
          select "Español", from: "Current language"

          expect(page).to have_field "Proposal title", with: "Título en español"

          fill_in "Proposal title", with: ""
          click_button "Save changes"

          expect(page).to have_css "#error_explanation"

          select "Español", from: "Current language"

          expect(page).to have_field "Proposal title", with: "", class: "is-invalid-input"
        end
      end
    end

    context "Globalize javascript interface" do
      let(:translatable) { create(:debate) }
      let(:path) { edit_debate_path(translatable) }

      scenario "Is rendered with translation interface feature enabled" do
        visit path

        expect(page).to have_css ".globalize-languages"
      end

      scenario "Is not rendered with translation interface feature disabled" do
        Setting["feature.translation_interface"] = nil

        visit path

        expect(page).not_to have_css ".globalize-languages"
      end
    end
  end
end
