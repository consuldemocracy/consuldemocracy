require "rails_helper"

describe "Admin custom information texts", :admin do
  scenario "page is correctly loaded" do
    visit admin_site_customization_information_texts_path

    click_link "Basic customization"
    expect(page).to have_content "Help about debates"
    expect(page).to have_content "Help about proposals"
    expect(page).to have_content "Help about voting"
    expect(page).to have_content "Help about collaborative legislation"
    expect(page).to have_content "Help with participatory budgets"

    within("#information-texts-tabs") { click_link "Debates" }
    expect(page).to have_content "Help about debates"

    within("#information-texts-tabs") { click_link "Community" }
    expect(page).to have_content "Access the community"

    within("#information-texts-tabs") { click_link "Proposals" }
    expect(page).to have_content "Create proposal"

    within "#information-texts-tabs" do
      click_link "Polls"
    end

    expect(page).to have_content "Results"

    click_link "Layouts"
    expect(page).to have_content "Accessibility"

    click_link "Emails"
    expect(page).to have_content "Confirm your email"

    within "#information-texts-tabs" do
      click_link "Management"
    end

    expect(page).to have_content "This user account is already verified."

    click_link "Welcome"
    expect(page).to have_content "See all debates"
  end

  scenario "check that tabs are highlight when click it" do
    visit admin_site_customization_information_texts_path

    within("#information-texts-tabs") { click_link "Proposals" }
    expect(find("a[href=\"/admin/site_customization/information_texts?tab=proposals\"].is-active"))
          .to have_content "Proposals"
  end

  context "Globalization" do
    scenario "Add a translation", :js do
      key = "debates.index.section_footer.title"

      visit admin_site_customization_information_texts_path

      select "Français", from: :add_language
      fill_in "contents[content_#{key}]values[value_fr]", with: "Aide personalise sur les débats"

      click_button "Save"

      expect(page).to have_content "Translation updated successfully"

      visit admin_site_customization_information_texts_path
      select "Français", from: :select_language

      expect(page).to have_content "Aide personalise sur les débats"
      expect(page).not_to have_content "Aide sur les débats"
    end

    scenario "Update a translation", :js do
      key = "proposals.show.share"
      create(:i18n_content, key: key, value_fr: "Partager la proposition")

      visit admin_site_customization_information_texts_path(tab: "proposals")

      select "Français", from: :select_language
      fill_in "contents_content_#{key}values_value_fr", with: "Partager personalise"

      click_button "Save"
      expect(page).to have_content "Translation updated successfully"

      visit admin_site_customization_information_texts_path(tab: "proposals")
      select "Français", from: :select_language

      expect(page).to have_content "Partager personalise"
      expect(page).not_to have_content "Partager la proposition"
    end

    scenario "Remove a translation", :js do
      first_key = "debates.form.debate_title"
      debate_title = create(:i18n_content, key: first_key,
                                           value_en: "Custom debate title",
                                           value_es: "Título personalizado de debate")

      second_key = "debates.new.start_new"
      page_title = create(:i18n_content, key: second_key,
                                          value_en: "Start a new debate",
                                          value_es: "Empezar un debate")

      visit admin_site_customization_information_texts_path(tab: "debates")

      select "Español", from: :select_language
      click_link "Remove language"
      click_button "Save"

      expect(page).not_to have_link "Español"

      visit admin_site_customization_information_texts_path(tab: "debates")
      select "English", from: :select_language

      expect(page).to have_content "Start a new debate"
      expect(page).to have_content "Custom debate title"

      debate_title.reload
      page_title.reload

      expect(page_title.value_es).to be(nil)
      expect(debate_title.value_es).to be(nil)
      expect(page_title.value_en).to eq("Start a new debate")
      expect(debate_title.value_en).to eq("Custom debate title")
    end
  end
end
