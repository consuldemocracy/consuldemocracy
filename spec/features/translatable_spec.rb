shared_examples "new_translatable" do |factory_name, path_name, input_fields, textarea_fields = {}|
  let(:language_texts) do
    {
      es:      "en español",
      en:      "in English",
      fr:      "en Français",
      "pt-BR": "Português"
    }
  end

  let(:translatable_class) { build(factory_name).class }
  let(:input_fields) { input_fields } # So it's accessible by methods
  let(:textarea_fields) { textarea_fields } # So it's accessible by methods
  let(:path_name) { path_name } # So it's accessible by methods
  let(:fields) { input_fields + textarea_fields.keys }

  let(:attributes) do
    fields.product(%i[en es]).map do |field, locale|
      [:"#{field}_#{locale}", text_for(field, locale)]
    end.to_h
  end

  let(:optional_fields) do
    fields.select do |field|
      translatable.translations.last.dup.tap { |duplicate| duplicate.send(:"#{field}=", "") }.valid?
    end
  end

  let(:required_fields) do
    fields - optional_fields
  end

  let(:user) { create(:user, :in_census) }

  let(:translatable) do
    if factory_name == "budget_phase"
      budget = create(:budget)
      budget.phases.last.update attributes
      budget.phases.last
    else
      create(factory_name, attributes)
    end
  end

  before do
    Setting["feature.translation_interface"] = true
    login_as(user)
  end

  context "Manage translations" do

    scenario "Add only single translation at once", :js do
      visit new_translatable_path

      fill_in_new_translatable_form :en
      click_button create_button_text

      expect(page).to have_content(successul_operation_notice)
    end

    scenario "Add single translation should persist introduced field values", :js do
      visit new_translatable_path

      fill_in_new_translatable_form :en
      click_button create_button_text

      check_introduced_values_at_translatable_edit_or_show_path(:en)
    end

    scenario "Add multiple translations at once", :js do
      visit new_translatable_path

      fill_in_new_translatable_form :en
      select "Français", from: :add_language
      fill_in_new_translatable_form :fr
      click_button create_button_text

      expect(page).to have_content(successul_operation_notice)
    end

    scenario "Add only single translation at once not having the current locale", :js do
      visit new_translatable_path
      click_link "Remove language"
      select "Français", from: :add_language

      fill_in_new_translatable_form :fr
      click_button create_button_text

      expect(page).to have_content(successul_operation_notice)
    end

    scenario "Add a translation for a locale with non-underscored name", :js do
      visit new_translatable_path
      click_link "Remove language"
      select "Português brasileiro", from: :add_language

      fill_in_new_translatable_form :"pt-BR"
      click_button create_button_text

      expect(page).to have_content(successul_operation_notice)
    end

    scenario "Add an invalid translation", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit new_translatable_path
      click_button create_button_text

      expect(page).to have_css "#error_explanation"
      expect_page_to_have_translatable_field field, :en, with: ""
    end

    scenario "Should show errors when submiting without any active translations", :js do
      skip("can't have invalid translations") if required_fields.empty?

      visit new_translatable_path
      click_link "Remove language"
      click_button create_button_text

      expect(page).to have_css "#error_explanation"
    end
  end

  context "Globalize javascript interface" do
    scenario "Highlight current locale", :js do
      visit new_translatable_path

      expect_to_have_language_selected "English"
    end

    scenario "Highlight new locale added", :js do
      visit new_translatable_path

      select("Español", from: "locale-switcher")

      expect_to_have_language_selected "Español"
    end

    scenario "Select a locale and add it to the form", :js do
      visit new_translatable_path

      select "Français", from: :add_language

      expect_page_to_have_translatable_field fields.sample, :fr, with: ""
    end

    scenario "Remove a translation", :js do
      visit new_translatable_path

      expect(find("#select_language").value).to eq "en"
      click_link "Remove language"

      expect_not_to_have_language("English")
    end

    context "Languages in use" do
      scenario "Show default description" do
        visit new_translatable_path

        expect(page).to have_content "1 language in use"
      end

      scenario "Increase description count after add new language", :js do
        visit new_translatable_path

        select "Español", from: :add_language

        expect(page).to have_content "2 languages in use"
      end

      scenario "Decrease description count after remove a language", :js do
        visit new_translatable_path

        click_link "Remove language"

        expect(page).to have_content "0 languages in use"
      end
    end

    context "When translation interface feature setting" do
      scenario "Is enabled translation interface should be rendered" do
        visit new_translatable_path

        expect(page).to have_css ".globalize-languages"
      end

      scenario "Is disabled translation interface should not be rendered" do
        Setting["feature.translation_interface"] = nil

        visit new_translatable_path

        expect(page).not_to have_css ".globalize-languages"
      end
    end
  end
end

def new_translatable_path
  case translatable_class.name
  when "Budget::Investment"
    budget = create(:budget_heading, name: "Everywhere").group.budget
    send path_name, budget
  else
    send path_name
  end
end

def check_introduced_values_at_translatable_edit_or_show_path(locale)
  case translatable_class.name
  when "Debate" || "Proposal"
    click_link "Edit"
    check_translatable_fields(locale)
  when "Budget::Investment"
    check_translatable_texts(locale)
  end
end

def check_translatable_fields(locale)
  fields.each do |field|
    text = text_for(field, locale)
    expect_page_to_have_translatable_field(field, locale, with: text)
  end
end

def check_translatable_texts(locale)
  fields.each do |field|
    text = text_for(field, locale)
    expect(page).to have_content text
  end
end

def fill_in_new_translatable_form(locale)
  fields.each { |field| fill_in_field field, locale, with: text_for(field, locale) }
  case translatable_class.name
  when "Budget::Investment"
    complete_investment_form
  when "Debate"
    complete_new_debate_form
  when "Proposal"
    complete_new_proposal_form
  end
end

def complete_investment_form
  select "Everywhere", from: "budget_investment_heading_id"
  fill_in "budget_investment_location", with: "City center"
  fill_in "budget_investment_organization_name", with: "T.I.A."
  fill_in "budget_investment_tag_list", with: "Towers"
  check   "budget_investment_terms_of_service"
end

def complete_new_debate_form
  check "debate_terms_of_service"
end

def complete_new_proposal_form
  check "proposal_terms_of_service"
end

def successul_operation_notice
  case translatable_class.name
  when "Budget::Investment"
    "Budget Investment created successfully"
  when "Proposal"
    "Proposal created successfully"
  when "Debate"
    "Debate created successfully"
  end
end

def create_button_text
  case translatable_class.name
  when "Debate"
    "Start a debate"
  when "Budget::Investment"
    "Create Investment"
  when "Proposal"
    "Create proposal"
  end
end
