shared_examples "translatable" do |factory_name, path_name, fields|
  let(:language_texts) do
    {
      es:      "en español",
      en:      "in English",
      fr:      "en Français",
      "pt-BR": "Português"
    }
  end

  let(:translatable_class) { build(factory_name).class }

  let(:attributes) do
    fields.product(%i[en es]).map do |field, locale|
      [:"#{field}_#{locale}", text_for(field, locale)]
    end.to_h
  end

  let(:translatable) { create(factory_name, attributes) }
  let(:path) { send(path_name, *resource_hierarchy_for(translatable)) }
  before { login_as(create(:administrator).user) }

  context "Manage translations" do
    before do
      if translatable_class.name == "I18nContent"
        skip "Translation handling is different for site customizations"
      end
    end

    scenario "Add a translation", :js do
      visit path

      select "Français", from: "translation_locale"

      fields.each do |field|
        fill_in field_for(field, :fr), with: text_for(field, :fr)
      end

      click_button update_button_text

      visit path
      field = fields.sample

      expect(page).to have_field(field_for(field, :en), with: text_for(field, :en))

      click_link "Español"
      expect(page).to have_field(field_for(field, :es), with: text_for(field, :es))

      click_link "Français"
      expect(page).to have_field(field_for(field, :fr), with: text_for(field, :fr))
    end

    scenario "Update a translation", :js do
      visit path

      click_link "Español"
      field = fields.sample
      updated_text = "Corrección de #{text_for(field, :es)}"

      fill_in field_for(field, :es), with: updated_text

      click_button update_button_text

      visit path

      expect(page).to have_field(field_for(field, :en), with: text_for(field, :en))

      select('Español', from: 'locale-switcher')

      expect(page).to have_field(field_for(field, :es), with: updated_text)
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

    scenario 'Change value of a translated field to blank', :js do
      possible_blanks = fields.select do |field|
        translatable.dup.tap { |duplicate| duplicate.send(:"#{field}=", '') }.valid?
      end

      skip("can't have translatable blank fields") if possible_blanks.empty?

      field = possible_blanks.sample

      visit path
      expect(page).to have_field(field_for(field, :en), with: text_for(field, :en))

      fill_in field_for(field, :en), with: ''
      click_button update_button_text

      visit path
      expect(page).to have_field(field_for(field, :en), with: '')
    end

    scenario "Add a translation for a locale with non-underscored name", :js do
      visit path
      field = fields.sample

      select "Português", from: "translation_locale"
      fill_in field_for(field, :pt_br), with: text_for(field, :"pt-BR")

      click_button update_button_text

      visit path

      select('Português', from: 'locale-switcher')

      expect(page).to have_field(field_for(field, :pt_br), with: text_for(field, :"pt-BR"))
    end
  end

  context "Globalize javascript interface" do
    scenario "Highlight current locale", :js do
      visit path

      expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

      select('Español', from: 'locale-switcher')

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

      expect(page).to have_field(field_for(field, :en), with: text_for(field, :en))

      click_link "Español"

      expect(page).to have_field(field_for(field, :es), with: text_for(field, :es))
    end

    scenario "Select a locale and add it to the form", :js do
      visit path

      select "Français", from: "translation_locale"

      expect(page).to have_link "Français"

      click_link "Français"

      expect(page).to have_field(field_for(fields.sample, :fr))
    end
  end
end

def text_for(field, locale)
  I18n.with_locale(locale) do
    "#{translatable_class.human_attribute_name(field)} #{language_texts[locale]}"
  end
end

def field_for(field, locale)
  if translatable_class.name == "I18nContent"
    "contents_content_#{translatable.key}values_#{field}_#{locale}"
  else
    "#{translatable_class.model_name.singular}_#{field}_#{locale}"
  end
end

# FIXME: button texts should be consistent. Right now, buttons don't
# even share the same colour.
def update_button_text
  case translatable_class.name
  when "Budget::Investment::Milestone"
    "Update milestone"
  when "AdminNotification"
    "Update notification"
  else
    "Save changes"
  end
end
