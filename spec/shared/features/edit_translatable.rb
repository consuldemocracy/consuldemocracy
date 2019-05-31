shared_examples "edit_translatable" do |factory_name, path_name, input_fields, textarea_fields = {}|
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

  let(:user) { create(:administrator).user }
  let(:translatable) do
    if factory_name == "budget_phase"
      budget = create(:budget)
      budget.phases.last.update attributes
      budget.phases.last
    else
      create(factory_name, attributes)
    end
  end
  let(:path) { send(path_name, *resource_hierarchy_for(translatable)) }

  before do
    login_as(user)

    if front_end_path_to_visit?(path_name)
      Setting["feature.translation_interface"] = true
      translatable.update(author: user)
    end
  end

  context "Manage translations" do
    before do
      if translatable_class.name == "I18nContent"
        skip "Translation handling is different for site customizations"
      end
    end

    describe "Should show first available fallback when current locale translation does not exist" do

      scenario "For all translatable except ActivePoll and Budget::Phase", :js do
        if translatable_class.name == "ActivePoll" || translatable_class.name == "Budget::Phase"
          skip("Skip because after updating it doesn't render the description")
        end
        attributes = fields.product(%i[fr]).map do |field, locale|
          [:"#{field}_#{locale}", text_for(field, locale)]
        end.to_h
        translatable.update(attributes)
        visit path

        select "English", from: :select_language
        click_link "Remove language"
        select "Español", from: :select_language
        click_link "Remove language"
        click_button update_button_text

        expect(page).to have_content "en Français"
      end

      scenario "For Budget::Phase", :js do
        if translatable_class.name != "Budget::Phase"
          skip("Skip because force visit budgets_path after update")
        end
        attributes = fields.product(%i[fr]).map do |field, locale|
          [:"#{field}_#{locale}", text_for(field, locale)]
        end.to_h
        translatable.update(attributes)
        visit path

        select "English", from: :select_language
        click_link "Remove language"
        select "Español", from: :select_language
        click_link "Remove language"
        click_button update_button_text
        visit budgets_path

        expect(page).to have_content "en Français"
      end

      scenario "For ActivePoll", :js do
        if translatable_class.name != "ActivePoll"
          skip("Skip because force visit polls_path after update")
        end
        attributes = fields.product(%i[fr]).map do |field, locale|
          [:"#{field}_#{locale}", text_for(field, locale)]
        end.to_h
        translatable.update(attributes)
        visit path

        select "English", from: :select_language
        click_link "Remove language"
        select "Español", from: :select_language
        click_link "Remove language"
        click_button update_button_text
        visit polls_path

        expect(page).to have_content "en Français"
      end

    end

    scenario "Add a translation", :js do
      visit path

      select "Français", from: "translation_locale"
      fields.each { |field| fill_in_field field, :fr, with: text_for(field, :fr) }
      click_button update_button_text

      visit path
      field = fields.sample

      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      click_link "Español"
      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)

      click_link "Français"
      expect_page_to_have_translatable_field field, :fr, with: text_for(field, :fr)
    end

    scenario "Add an invalid translation", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit path

      select "Français", from: "translation_locale"
      fill_in_field field, :fr, with: ""
      click_button update_button_text

      expect(page).to have_css "#error_explanation"

      click_link "Français"

      expect_page_to_have_translatable_field field, :fr, with: ""
    end

    scenario "Update a translation", :js do
      visit path

      click_link "Español"
      field = fields.sample
      updated_text = "Corrección de #{text_for(field, :es)}"

      fill_in_field field, :es, with: updated_text

      click_button update_button_text

      visit path

      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      select("Español", from: "locale-switcher")

      expect_page_to_have_translatable_field field, :es, with: updated_text
    end

    scenario "Update a translation with invalid data", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit path
      click_link "Español"

      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)

      fill_in_field field, :es, with: ""
      click_button update_button_text

      expect(page).to have_css "#error_explanation"

      click_link "Español"

      expect_page_to_have_translatable_field field, :es, with: ""
    end

    scenario "Update a translation not having the current locale", :js do
      translatable.translations.destroy_all

      translatable.translations.create(
        fields.map { |field| [field, text_for(field, :fr)] }.to_h.merge(locale: :fr)
      )

      visit path

      expect(page).not_to have_link "English"
      expect(page).to have_link "Français"

      click_button update_button_text

      expect(page).not_to have_css "#error_explanation"

      path = updated_path_for(translatable)
      visit path

      expect(page).not_to have_link "English"
      expect(page).to have_link "Français"
    end

    scenario "Remove a translation", :js do
      visit path

      click_link "Español"
      click_link "Remove language"

      expect(page).not_to have_link "Español"

      click_button update_button_text

      visit path
      expect(page).not_to have_link "Español"
    end

    scenario "Remove a translation with invalid data", :js do
      skip("can't have invalid translations") if required_fields.empty?

      field = required_fields.sample

      visit path

      click_link "Español"
      click_link "Remove language"

      click_link "English"
      fill_in_field field, :en, with: ""
      click_button update_button_text

      expect(page).to have_css "#error_explanation"
      expect_page_to_have_translatable_field field, :en, with: ""
      expect(page).not_to have_link "Español"

      visit path
      click_link "Español"

      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)
    end

    scenario "Change value of a translated field to blank", :js do
      skip("can't have translatable blank fields") if optional_fields.empty?

      field = optional_fields.sample

      visit path
      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      fill_in_field field, :en, with: ""
      click_button update_button_text

      visit path
      expect_page_to_have_translatable_field field, :en, with: ""
    end

    scenario "Add a translation for a locale with non-underscored name", :js do
      visit path

      select "Português brasileiro", from: "translation_locale"
      fields.each { |field| fill_in_field field, :"pt-BR", with: text_for(field, :"pt-BR") }
      click_button update_button_text

      visit path

      select("Português brasileiro", from: "locale-switcher")

      field = fields.sample
      expect_page_to_have_translatable_field field, :"pt-BR", with: text_for(field, :"pt-BR")
    end
  end

  context "Globalize javascript interface" do
    scenario "Highlight current locale", :js do
      visit path

      expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

      select("Español", from: "locale-switcher")

      expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
    end

    scenario "Highlight selected locale", :js do
      visit path

      expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

      click_link "Español"

      expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
    end

    scenario "Show selected locale form", :js do
      visit path
      field = fields.sample

      expect_page_to_have_translatable_field field, :en, with: text_for(field, :en)

      click_link "Español"

      expect_page_to_have_translatable_field field, :es, with: text_for(field, :es)
    end

    scenario "Select a locale and add it to the form", :js do
      visit path

      select "Français", from: "translation_locale"

      expect(page).to have_link "Français"

      click_link "Français"

      expect_page_to_have_translatable_field fields.sample, :fr, with: ""
    end

    context "Languages in use" do
      scenario "Show default description" do
        visit path

        expect(page).to have_content "2 languages in use"
      end

      scenario "Increase description count after add new language", :js do
        visit path

        select "Français", from: :add_language

        expect(page).to have_content "3 languages in use"
      end

      scenario "Decrease description count after remove a language", :js do
        visit path

        click_link "Remove language"

        expect(page).to have_content "1 language in use"
      end
    end
  end
end

def updated_path_for(resource)
  send(path_name, *resource_hierarchy_for(resource.reload))
end

# FIXME: button texts should be consistent. Right now, buttons don't
# even share the same colour.
def update_button_text
  case translatable_class.name
  when "Milestone"
    "Update milestone"
  when "AdminNotification"
    "Update notification"
  when "Budget::Investment"
    "Update"
  when "Poll"
    "Update poll"
  when "Budget"
    "Update Budget"
  when "Poll::Question", "Poll::Question::Answer", "ActivePoll"
    "Save"
  when "SiteCustomization::Page"
    "Update Custom page"
  when "Widget::Card"
    "Save card"
  when "Budget::Group"
    "Save group"
  when "Budget::Heading"
    "Save heading"
  else
    "Save changes"
  end
end
