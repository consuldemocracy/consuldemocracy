require 'rails_helper'

feature 'Admin legislation draft versions' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "translatable",
                  "legislation_draft_version",
                  "edit_admin_legislation_process_draft_version_path",
                  %w[title changelog]

  context "Feature flag" do

    scenario 'Disabled with a feature flag' do
      Setting['feature.legislation'] = nil
      process = create(:legislation_process)
      expect{ visit admin_legislation_process_draft_versions_path(process) }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario 'Displaying legislation process draft versions' do
      process = create(:legislation_process, title: 'An example legislation process')
      draft_version = create(:legislation_draft_version, process: process, title: 'Version 1')

      visit admin_legislation_processes_path(filter: 'all')

      click_link 'An example legislation process'
      click_link 'Drafting'
      click_link 'Version 1'

      expect(page).to have_content(draft_version.title)
      expect(page).to have_content(draft_version.changelog)
    end
  end

  context 'Create' do
    scenario 'Valid legislation draft version' do
      process = create(:legislation_process, title: 'An example legislation process')

      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      click_link "All"

      expect(page).to have_content 'An example legislation process'

      click_link 'An example legislation process'
      click_link 'Drafting'

      click_link 'Create version'

      fill_in 'legislation_draft_version_title_en', with: 'Version 3'
      fill_in 'legislation_draft_version_changelog_en', with: 'Version 3 changes'
      fill_in 'legislation_draft_version_body_en', with: 'Version 3 body'

      within('.end') do
        click_button 'Create version'
      end

      expect(page).to have_content 'An example legislation process'
      expect(page).to have_content 'Version 3'
    end
  end

  context 'Update' do
    scenario 'Valid legislation draft version', :js do
      process = create(:legislation_process, title: 'An example legislation process')
      draft_version = create(:legislation_draft_version, title: 'Version 1', process: process)

      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      click_link "All"

      expect(page).to have_content 'An example legislation process'

      click_link 'An example legislation process'
      click_link 'Drafting'

      click_link 'Version 1'

      fill_in 'legislation_draft_version_title_en', with: 'Version 1b'

      click_link 'Launch text editor'

      fill_in 'legislation_draft_version_body_en', with: '# Version 1 body\r\n\r\nParagraph\r\n\r\n>Quote'

      within('.fullscreen') do
        click_link 'Close text editor'
      end

      click_button 'Save changes'

      expect(page).to have_content 'Version 1b'
    end
  end

  context "Translations" do

    let!(:draft_version) { create(:legislation_draft_version,
                                    title_en: "Title in English",
                                    title_es: "Título en Español",
                                    changelog_en: "Changes in English",
                                    changelog_es: "Cambios en Español",
                                    body_en: "Body in English",
                                    body_es: "Texto en Español") }

    before do
      @edit_draft_version_url = edit_admin_legislation_process_draft_version_path(draft_version.process, draft_version)
    end

    scenario "Add a translation", :js do
      visit @edit_draft_version_url

      select "Français", from: "translation_locale"
      fill_in 'legislation_draft_version_title_fr', with: 'Titre en Français'

      click_button 'Save changes'

      visit @edit_draft_version_url
      expect(page).to have_field('legislation_draft_version_title_en', with: 'Title in English')

      click_link "Español"
      expect(page).to have_field('legislation_draft_version_title_es', with: 'Título en Español')

      click_link "Français"
      expect(page).to have_field('legislation_draft_version_title_fr', with: 'Titre en Français')
    end

    scenario "Update a translation", :js do
      draft_version.update!(status: 'published')
      draft_version.process.update!(title_es: 'Título de proceso')

      visit @edit_draft_version_url

      click_link "Español"
      fill_in 'legislation_draft_version_title_es', with: 'Título correcto en Español'

      click_button 'Save changes'

      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      expect(page).to have_content("Title in English")

      select('Español', from: 'locale-switcher')

      expect(page).to have_content('Título correcto en Español')
    end

    scenario "Remove a translation", :js do
      visit @edit_draft_version_url

      click_link "Español"
      click_link "Remove language"

      expect(page).not_to have_link "Español"

      click_button "Save changes"
      visit @edit_draft_version_url
      expect(page).not_to have_link "Español"
    end

    scenario 'Add translation through markup editor', :js do
      visit @edit_draft_version_url

      select "Français", from: "translation_locale"

      click_link 'Launch text editor'

      fill_in 'legislation_draft_version_body_fr', with: 'Texte en Français'

      click_link 'Close text editor'
      click_button "Save changes"

      visit @edit_draft_version_url

      click_link "Français"
      click_link 'Launch text editor'

      expect(page).to have_field('legislation_draft_version_body_fr', with: 'Texte en Français')
    end

    context "Globalize javascript interface" do

      scenario "Highlight current locale", :js do
        visit @edit_draft_version_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        select('Español', from: 'locale-switcher')

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Highlight selected locale", :js do
        visit @edit_draft_version_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        click_link "Español"

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Show selected locale form", :js do
        visit @edit_draft_version_url

        expect(page).to have_field('legislation_draft_version_title_en', with: 'Title in English')

        click_link "Español"

        expect(page).to have_field('legislation_draft_version_title_es', with: 'Título en Español')
      end

      scenario "Select a locale and add it to the draft_version form", :js do
        visit @edit_draft_version_url

        select "Français", from: "translation_locale"

        expect(page).to have_link "Français"

        click_link "Français"

        expect(page).to have_field('legislation_draft_version_title_fr')
      end
    end
  end
end
