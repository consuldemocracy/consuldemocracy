require "rails_helper"

describe "Admin custom information texts" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "translatable",
                  "i18n_content",
                  "admin_site_customization_information_texts_path",
                  %w[value]

  scenario "page is correctly loaded" do
    visit admin_site_customization_information_texts_path

    click_link "Basic customization"
    expect(page).to have_content "Help about debates"
    expect(page).to have_content "Help about proposals"
    expect(page).to have_content "Help about voting"
    expect(page).to have_content "Help about collaborative legislation"
    expect(page).to have_content "Help with participatory budgets"

    click_link "Debates"
    expect(page).to have_content "Help about debates"

    click_link "Community"
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

      select "Français", from: "translation_locale"
      fill_in "contents[content_#{key}]values[value_fr]", with: "Aide personalise sur les débats"

      click_button "Save"

      expect(page).to have_content "Translation updated successfully"

      visit admin_site_customization_information_texts_path

      select "Français", from: "translation_locale"
      expect(page).to have_content "Aide personalise sur les débats"
      expect(page).not_to have_content "Aide sur les débats"
    end

    scenario "Update a translation", :js do
      key = "proposals.form.proposal_title"

      visit admin_site_customization_information_texts_path(tab: "proposals")

      select "Français", from: "translation_locale"
      fill_in "contents_content_#{key}values_value_fr", with: "Titre personalise de la proposition"

      click_button "Save"
      expect(page).to have_content "Translation updated successfully"

      visit admin_site_customization_information_texts_path(tab: "proposals")
      click_link "Français"

      expect(page).to have_content "Titre personalise de la proposition"
      expect(page).not_to have_content "Titre de la proposition"
    end

    scenario "Remove a translation", :js do
      first_key = "debates.form.debate_title"
      debate_title = create(:i18n_content, key: first_key,
                                           value_en: "Custom debate title",
                                           value_es: "Título personalizado de debate")

      second_key = "debates.form.debate_text"
      debate_text = create(:i18n_content, key: second_key,
                                          value_en: "Custom debate text",
                                          value_es: "Texto personalizado de debate")

      visit admin_site_customization_information_texts_path(tab: "debates")

      click_link "Español"
      click_link "Remove language"
      click_button "Save"

      expect(page).not_to have_link "Español"

      visit admin_site_customization_information_texts_path(tab: "debates")
      click_link "English"
      expect(page).to have_content "Custom debate text"
      expect(page).to have_content "Custom debate title"

      debate_title.reload
      debate_text.reload

      expect(debate_text.value_es).to be(nil)
      expect(debate_title.value_es).to be(nil)
      expect(debate_text.value_en).to eq("Custom debate text")
      expect(debate_title.value_en).to eq("Custom debate title")
    end
  end

end
