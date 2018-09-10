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

  context "Special translation behaviour" do

    let!(:draft_version) { create(:legislation_draft_version) }

    scenario 'Add body translation through markup editor', :js do
      edit_path = edit_admin_legislation_process_draft_version_path(draft_version.process, draft_version)

      visit edit_path

      select "Français", from: "translation_locale"

      click_link 'Launch text editor'

      fill_in 'legislation_draft_version_body_fr', with: 'Texte en Français'

      click_link 'Close text editor'
      click_button "Save changes"

      visit edit_path

      click_link "Français"
      click_link 'Launch text editor'

      expect(page).to have_field('legislation_draft_version_body_fr', with: 'Texte en Français')
    end
  end
end
