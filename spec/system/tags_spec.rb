require "rails_helper"

describe "Tags" do
  scenario "Index" do
    earth = create(:debate, tag_list: "Medio Ambiente")
    money = create(:debate, tag_list: "Economía")

    visit debates_path

    within "#debate_#{earth.id}" do
      expect(page).to have_content "Medio Ambiente"
    end

    within "#debate_#{money.id}" do
      expect(page).to have_content "Economía"
    end
  end

  scenario "Filtered" do
    debate1 = create(:debate, tag_list: "Salud")
    debate2 = create(:debate, tag_list: "salud")
    debate3 = create(:debate, tag_list: "Hacienda")
    debate4 = create(:debate, tag_list: "Hacienda")

    visit debates_path
    first(:link, "Salud").click

    within("#debates") do
      expect(page).to have_css(".debate", count: 2)
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
      expect(page).not_to have_content(debate3.title)
      expect(page).not_to have_content(debate4.title)
    end

    visit debates_path(search: "salud")

    within("#debates") do
      expect(page).to have_css(".debate", count: 2)
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
      expect(page).not_to have_content(debate3.title)
      expect(page).not_to have_content(debate4.title)
    end
  end

  scenario "Show" do
    debate = create(:debate, tag_list: "Hacienda, Economía")

    visit debate_path(debate)

    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
  end

  scenario "Create" do
    user = create(:user)
    login_as(user)

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"

    fill_in_tag_list "Impuestos, Economía, Hacienda"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
    expect(page).to have_content "Impuestos"
  end

  scenario "Create with too many tags" do
    user = create(:user)
    login_as(user)

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"

    fill_in_tag_list "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button "Start a debate"

    expect(page).to have_content error_message
    expect(page).to have_content "tags must be less than or equal to 6"
    expect(page).to have_css "[data-value='Impuestos']"
    expect(page).to have_css "[data-value='Igualdad']"
  end

  scenario "Keeps names with quotes, apostrophes and accents" do
    debate = create(:debate, tag_list: ["Say \"hi\"", "It's fine", "Economía"])

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_css "[data-value='Say \"hi\"']"
    expect(page).to have_css "[data-value=\"It's fine\"]"
    expect(page).to have_css "[data-value='Economía']"

    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."
    expect(debate.reload.tag_list).to contain_exactly("Say \"hi\"", "It's fine", "Economía")
  end

  scenario "Does not add a case-variant duplicate" do
    user = create(:user)
    login_as(user)

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in_tag_list "Economía, economía"

    expect(page).to have_css "[data-value='Economía']", count: 1
    expect(page).not_to have_css "[data-value='economía']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(Debate.last.tag_list).to eq(["Economía"])
  end

  scenario "Exposes only the interactive tag field to assistive technology" do
    login_as(create(:user))
    visit new_debate_path

    expect_accessible_tag_field

    within ".subnavigation" do
      click_link "Debates"
    end

    click_link "Start a debate"

    expect_accessible_tag_field

    fill_in_tag_list "Hacienda"
    expect(find(".js-taggable-fields input.js-tag-list", visible: :all).value).to eq "Hacienda"

    page.execute_script("App.ListField.destroy()")

    within ".js-taggable-fields" do
      original = find("input.js-tag-list")

      expect(original["aria-hidden"]).to be_nil
      expect(original.value).to eq "Hacienda"
      expect(original).not_to be_disabled
      expect(find("label", text: "Tags")[:for]).to eq original[:id]
      expect(page).not_to have_css ".ts-wrapper"
    end

    page.execute_script("App.Tags.initialize()")

    expect_accessible_tag_field
    expect(page).to have_css ".js-taggable-fields [data-value='Hacienda']"
  end

  scenario "Update" do
    debate = create(:debate, tag_list: "Economía")

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_css ".js-taggable-fields [data-value='Economía']"

    fill_in_tag_list "Hacienda"
    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."
    within(".tags") do
      expect(page).to have_link "Economía"
      expect(page).to have_link "Hacienda"
    end
  end

  scenario "Delete" do
    debate = create(:debate, tag_list: "Economía")

    login_as(debate.author)
    visit edit_debate_path(debate)

    clear_tag_list
    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."
    expect(page).not_to have_content "Economía"
  end

  context "Tag cloud" do
    scenario "Proposals" do
      create(:proposal, tag_list: "Medio Ambiente")
      create(:proposal, tag_list: "Economía")

      visit proposals_path

      within "#tag-cloud" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "Debates" do
      create(:debate, tag_list: "Medio Ambiente")
      create(:debate, tag_list: "Economía")

      visit debates_path

      within "#tag-cloud" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "scoped by category" do
      create(:tag, :category, name: "Medio Ambiente")
      create(:tag, :category, name: "Economía")

      create(:proposal, tag_list: "Medio Ambiente, Agua")
      create(:proposal, tag_list: "Economía, Corrupción")

      visit proposals_path(search: "Economía")

      within "#tag-cloud" do
        expect(page).to have_css(".tag", count: 1)
        expect(page).to have_content "Corrupción"
        expect(page).not_to have_content "Economía"
      end
    end

    scenario "scoped by district" do
      create(:geozone, name: "Madrid")
      create(:geozone, name: "Barcelona")

      create(:proposal, tag_list: "Madrid, Agua")
      create(:proposal, tag_list: "Barcelona, Playa")

      visit proposals_path(search: "Barcelona")

      within "#tag-cloud" do
        expect(page).to have_css(".tag", count: 1)
        expect(page).to have_content "Playa"
        expect(page).not_to have_content "Agua"
      end
    end

    scenario "tag links" do
      proposal1 = create(:proposal, tag_list: "Medio Ambiente")
      proposal2 = create(:proposal, tag_list: "Medio Ambiente")
      proposal3 = create(:proposal, tag_list: "Economía")

      visit proposals_path

      within "#tag-cloud" do
        click_link "Medio Ambiente"
      end

      expect(page).to have_css ".proposal", count: 2
      expect(page).to have_content proposal1.title
      expect(page).to have_content proposal2.title
      expect(page).not_to have_content proposal3.title
    end
  end

  def expect_accessible_tag_field
    within ".js-taggable-fields" do
      original = find("input.js-tag-list", visible: :all)
      control = find("input.js-tag-list-input")
      label = find("label", text: "Tags")

      expect(original["aria-hidden"]).to eq "true"
      expect(original["tabindex"]).to eq "-1"
      expect(original[:class]).to include "ts-hidden-accessible"
      expect(original).not_to be_disabled
      expect(original[:name]).to eq "debate[tag_list]"

      expect(label[:for]).to eq control[:id]
      expect(control["aria-labelledby"]).to eq label[:id]
      expect(control["aria-hidden"]).to be_nil
      expect(control["tabindex"]).to eq "0"

      label.click
    end

    expect(page.evaluate_script("document.activeElement.id")).to eq find(".js-tag-list-input")[:id]
  end
end
