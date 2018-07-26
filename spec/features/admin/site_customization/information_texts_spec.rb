require 'rails_helper'

feature "Admin custom information texts" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'page is correctly loaded' do
    visit admin_site_customization_information_texts_path

    click_link 'Debates'
    expect(page).to have_content 'Help about citizen debates'

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
    expect(page).to have_content 'See all recommended debates'
  end

  scenario 'can be changed and they are correctly shown' do
    content  = create(:i18n_content)
    old_text = content.value_en

    visit admin_site_customization_information_texts_path

    select 'English', from: 'translation_locale'
    fill_in "contents_content_#{content.key}values_value_en", with: 'Custom debates text'
    click_button "Save"

    visit debates_path

    expect(page).to have_content 'Custom debates text'
    expect(page).not_to have_content old_text
  end

  scenario 'change according to current locale', :js do
    content = create(:i18n_content)

    visit debates_path

    expect(page).to have_content content.value_en
    expect(page).not_to have_content content.value_es

    select('Español', from: 'locale-switcher')

    expect(page).to have_content content.value_es
    expect(page).not_to have_content content.value_en
  end

  scenario 'languages can be added', :js do
    content = create(:i18n_content, key: 'debates.form.debate_text')

    visit admin_site_customization_information_texts_path(locale: :fr)

    select 'Français', from: 'translation_locale'

    click_link 'Français'
    expect(page).to have_css('a.is-active', text: 'Français')

    fill_in "contents_content_#{content.key}values_value_fr", with: 'Nouvelle titre en français'
    click_button 'Enregistrer'

    content.reload

    expect(page).to have_content 'Nouvelle titre en français'
    expect(content.value_fr).to eq 'Nouvelle titre en français'
  end

  scenario 'languages can be removed', :js do
    content = create(:i18n_content)

    visit admin_site_customization_information_texts_path

    click_link 'Español'
    expect(page).to have_css('a.is-active', text: 'Español')

    click_link 'Remove language'
    expect(page).not_to have_link('Español')

    click_button 'Save'

    content.reload

    expect(content.value_es).to be nil
    expect(page).not_to have_content 'Texto en español'
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
      visit @edit_milestone_url

      click_link "Español"
      click_link "Remove language"

      expect(page).not_to have_link "Español"

      click_button "Update milestone"
      visit @edit_milestone_url
      expect(page).not_to have_link "Español"
    end

    context "Globalize javascript interface" do

      scenario "Highlight current locale", :js do
        visit @edit_milestone_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        select('Español', from: 'locale-switcher')

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Highlight selected locale", :js do
        visit @edit_milestone_url

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "English"

        click_link "Español"

        expect(find("a.js-globalize-locale-link.is-active")).to have_content "Español"
      end

      scenario "Show selected locale form", :js do
        visit @edit_milestone_url

        expect(page).to have_field('budget_investment_milestone_description_en', with: 'Description in English')

        click_link "Español"

        expect(page).to have_field('budget_investment_milestone_description_es', with: 'Descripción en Español')
      end

      scenario "Select a locale and add it to the milestone form", :js do
        visit @edit_milestone_url

        select "Français", from: "translation_locale"

        expect(page).to have_link "Français"

        click_link "Français"

        expect(page).to have_field('budget_investment_milestone_description_fr')
      end
    end

  end

end
