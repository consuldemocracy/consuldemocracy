shared_examples "translatable" do |factory_name, path_name, fields|
  let(:language_texts)     { { es: "en español", en: "in English", fr: "en Français" } }
  let(:translatable_class) { build(factory_name).class }

  let(:attributes) do
    fields.product(%i[en es]).map do |field, locale|
      [:"#{field}_#{locale}", text_for(field, locale)]
    end.to_h
  end

  let(:translatable) { create(factory_name, attributes) }
  let(:path) { send(path_name, *resource_hierarchy_for(translatable)) }
  before { login_as(create(:administrator).user) }

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
      field = fields.last # TODO: not sure about first, last, or sample

      expect(page).to have_field(field_for(field, :en), with: text_for(field, :en))

      click_link "Español"

      expect(page).to have_field(field_for(field, :es), with: text_for(field, :es))
    end

    scenario "Select a locale and add it to the form", :js do
      visit path

      select "Français", from: "translation_locale"

      expect(page).to have_link "Français"

      click_link "Français"

      expect(page).to have_field(field_for(fields.last, :fr))
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
