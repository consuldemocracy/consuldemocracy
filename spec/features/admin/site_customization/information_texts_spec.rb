require 'rails_helper'

feature "Admin custom information texts" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'page is correctly loaded' do
    visit admin_site_customization_information_texts_path

    click_link 'Debates'
    expect(page).to have_content 'Help about debates'

    click_link 'Community'
    expect(page).to have_content 'Access the community'

    click_link 'Proposals'
    expect(page).to have_content 'Create proposal'

    within "#information-texts-tabs" do
      click_link "Polls"
    end

    expect(page).to have_content 'Results'

    click_link 'Layouts'
    expect(page).to have_content 'Accessibility'

    click_link 'Emails'
    expect(page).to have_content 'Confirm your email'

    within "#information-texts-tabs" do
      click_link "Management"
    end

    expect(page).to have_content 'This user account is already verified.'

    click_link 'Guides'
    expect(page).to have_content 'Choose what you want to create'

    click_link 'Welcome'
    expect(page).to have_content 'See all debates'
  end
  
  scenario 'check that tabs are highlight when click it' do
    visit admin_site_customization_information_texts_path

    click_link 'Proposals'
    expect(find("a[href=\"/admin/site_customization/information_texts?tab=proposals\"].is-active")).to have_content "Proposals"
  end

  context "Globalization" do

    scenario "Add a translation", :js do
      key = "debates.form.debate_title"

      visit admin_site_customization_information_texts_path

      select "Français", from: "translation_locale"
      fill_in "contents_content_#{key}values_value_fr", with: 'Titre personalise du débat'

      click_button "Save"

      expect(page).to have_content 'Translation updated successfully'

      select "Français", from: "translation_locale"

      expect(page).to have_content 'Titre personalise du débat'
      expect(page).not_to have_content 'Titre du débat'
    end

    scenario "Update a translation", :js do
      key = "debates.form.debate_title"
      content = create(:i18n_content, key: key, value_fr: 'Titre personalise du débat')

      visit admin_site_customization_information_texts_path

      select "Français", from: "translation_locale"
      fill_in "contents_content_#{key}values_value_fr", with: 'Titre personalise again du débat'

      click_button 'Save'
      expect(page).to have_content 'Translation updated successfully'

      click_link 'Français'

      expect(page).to have_content 'Titre personalise again du débat'
      expect(page).not_to have_content 'Titre personalise du débat'
    end

    scenario "Remove a translation", :js do
      first_key = "debates.form.debate_title"
      debate_title = create(:i18n_content, key: first_key,
                                           value_en: 'Custom debate title',
                                           value_es: 'Título personalizado de debate')

      second_key = "debates.form.debate_text"
      debate_text = create(:i18n_content, key: second_key,
                                          value_en: 'Custom debate text',
                                          value_es: 'Texto personalizado de debate')

      visit admin_site_customization_information_texts_path

      click_link "Español"
      click_link "Remove language"
      click_button "Save"

      expect(page).not_to have_link "Español"

      click_link 'English'
      expect(page).to have_content 'Custom debate text'
      expect(page).to have_content 'Custom debate title'

      debate_title.reload
      debate_text.reload

      expect(debate_text.value_es).to be(nil)
      expect(debate_title.value_es).to be(nil)
      expect(debate_text.value_en).to eq('Custom debate text')
      expect(debate_title.value_en).to eq('Custom debate title')
    end

    context "Javascript interface" do

      scenario "Highlight current locale", :js do
        visit admin_site_customization_information_texts_path

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        select('Español', from: 'locale-switcher')

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Highlight selected locale", :js do
        key = "debates.form.debate_title"
        content = create(:i18n_content, key: key, value_es: 'Título')

        visit admin_site_customization_information_texts_path

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        click_link "Español"

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Show selected locale form", :js do
        key = "debates.form.debate_title"
        content = create(:i18n_content, key: key,
                                        value_en: 'Title',
                                        value_es: 'Título')

        visit admin_site_customization_information_texts_path

        expect(page).to have_field("contents_content_#{key}values_value_en", with: 'Title')

        click_link "Español"

        expect(page).to have_field("contents_content_#{key}values_value_es", with: 'Título')
      end

      scenario "Select a locale and add it to the form", :js do
        key = "debates.form.debate_title"

        visit admin_site_customization_information_texts_path
        select "Français", from: "translation_locale"

        expect(page).to have_link "Français"

        click_link "Français"
        expect(page).to have_field("contents_content_#{key}values_value_fr")
      end
    end

  end

end
