module Translations
  def text_for(field, locale)
    I18n.with_locale(locale) do
      "#{translatable_class.human_attribute_name(field)} #{language_texts[locale]}"
    end
  end

  def field_for(field, locale, visible: true)
    if translatable_class.name == "I18nContent"
      "contents_content_#{translatable.key}values_#{field}_#{locale}"
    else
      within(".translatable-fields[data-locale='#{locale}']") do
        find("input[id$='_#{field}'], textarea[id$='_#{field}']", visible: visible)[:id]
      end
    end
  end

  def fill_in_field(field, locale, with:)
    if input_fields.include?(field)
      fill_in field_for(field, locale), with: with
    else
      fill_in_textarea(field, textarea_fields[field], locale, with: with)
    end
  end

  def fill_in_textarea(field, textarea_type, locale, with:)
    if textarea_type == :markdownit
      click_link class: "fullscreen-toggle"
      fill_in field_for(field, locale), with: with
      click_link class: "fullscreen-toggle"
    elsif textarea_type == :ckeditor
      fill_in_ckeditor field_for(field, locale, visible: false), with: with
    end
  end

  def expect_page_to_have_translatable_field(field, locale, with:)
    if input_fields.include?(field)
      if translatable_class.name == "I18nContent" && with.blank?
        expect(page).to have_field field_for(field, locale)
      else
        expect(page).to have_field field_for(field, locale), with: with
      end
    else
      textarea_type = textarea_fields[field]

      if textarea_type == :markdownit
        click_link class: "fullscreen-toggle"
        expect(page).to have_field field_for(field, locale), with: with
        click_link class: "fullscreen-toggle"
      elsif textarea_type == :ckeditor
        within("div.js-globalize-attribute[data-locale='#{locale}'] .ckeditor [id$='#{field}']") do
          # Wait longer for iframe initialization
          expect(page).to have_selector "iframe.cke_wysiwyg_frame", wait: 5
          within_frame(textarea_fields.keys.index(field)) { expect(page).to have_content with }
        end
      end
    end
  end

  def front_end_path_to_visit?(path)
    path[/admin|managment|valuation|tracking/].blank?
  end

  def expect_to_have_language(language)
    expect(page).to have_select :select_language, with_options: [language]
  end

  def expect_not_to_have_language(language)
    expect(page).not_to have_select :select_language, with_options: [language]
  end

  def expect_to_have_language_selected(language)
    expect(page).to have_select :select_language, selected: language
  end
end
