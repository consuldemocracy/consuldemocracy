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
  end

  scenario "Create without JavaScript", :no_js do
    login_as(create(:user))

    visit new_debate_path

    expect(page).to have_css ".taggable-fields .help-text",
                             text: "Enter the tags you would like to use, separated by commas (',')"
    expect(page).not_to have_css ".taggable-fields input[placeholder]"

    fill_in "Debate title", with: "Title"
    fill_in "Initial debate text", with: "Description"
    fill_in "Tags", with: "Impuestos, Economía"
    check "debate_terms_of_service"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_link "Impuestos"
    expect(page).to have_link "Economía"
  end

  scenario "Tag instructions stay visible after adding a tag" do
    login_as(create(:user))

    visit new_debate_path
    fill_in_tag_list "Economía"

    expect(page).to have_css ".taggable-fields .item[data-value='Economía']"
    expect(page).to have_css ".taggable-fields .help-text",
                             text: "Enter the tags you would like to use, separated by commas (',')"
    expect(page).not_to have_css ".taggable-fields input[placeholder]"
  end

  scenario "Create with a tag not followed by a comma" do
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "Impuestos"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_link "Impuestos"
  end

  scenario "Create with a suggested tag" do
    create(:tag, name: "Hacienda")
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "Ha"

    within(".ts-dropdown") { find("[data-value='Hacienda']").click }

    expect(page).to have_css ".item[data-value='Hacienda']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_link "Hacienda"
  end

  scenario "Create with the typed tag pressing enter while suggestions are shown" do
    create(:tag, name: "Agua potable")
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "agua"

    expect(page).to have_css ".ts-dropdown [data-value='Agua potable']"

    find_field("Tags").send_keys :enter

    expect(page).to have_css ".taggable-fields .item", count: 1
    expect(page).to have_css ".item[data-value='agua']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."

    within(".tags") do
      expect(page).to have_link count: 1
      expect(page).to have_link "agua"
    end
  end

  scenario "Create with a suggested tag chosen with the keyboard" do
    create(:tag, name: "Agua potable")
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "agua"

    expect(page).to have_css ".ts-dropdown [data-value='Agua potable']"

    find_field("Tags").send_keys :down, :enter

    expect(page).to have_css ".taggable-fields .item", count: 1
    expect(page).to have_css ".item[data-value='Agua potable']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."

    within(".tags") do
      expect(page).to have_link count: 1
      expect(page).to have_link "Agua potable"
    end
  end

  scenario "Create with an existing tag typed in another case" do
    create(:tag, name: "Agua potable")
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "agua potable"

    expect(page).to have_css ".ts-dropdown [data-value='Agua potable']"
    expect(page).not_to have_css ".ts-dropdown .create"

    find_field("Tags").send_keys :enter

    expect(page).to have_css ".taggable-fields .item", count: 1
    expect(page).to have_css ".item[data-value='Agua potable']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."

    within(".tags") do
      expect(page).to have_link count: 1
      expect(page).to have_link "Agua potable"
    end
  end

  scenario "Create with an existing tag typed in another case and no comma" do
    create(:tag, name: "Agua potable")
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "agua potable"

    expect(page).to have_css ".ts-dropdown [data-value='Agua potable']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."

    within(".tags") do
      expect(page).to have_link count: 1
      expect(page).to have_link "Agua potable"
    end
  end

  scenario "Create with a tag not followed by a comma while suggestions are shown" do
    create(:tag, name: "Agua potable")
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in "Tags", with: "agua"

    expect(page).to have_css ".ts-dropdown [data-value='Agua potable']"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."

    within(".tags") do
      expect(page).to have_link count: 1
      expect(page).to have_link "agua"
    end
  end

  scenario "Create with tags that only differ in case" do
    login_as(create(:user))

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"
    check "debate_terms_of_service"
    fill_in_tag_list "Economía, economía"

    expect(page).to have_css ".taggable-fields .item", count: 1

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."

    within(".tags") do
      expect(page).to have_link count: 1
      expect(page).to have_link "Economía"
    end
  end

  scenario "Update keeps tags with quotes, apostrophes and accents" do
    debate = create(:debate, tag_list: ["Say \"hi\"", "It's fine", "Economía"])

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_css ".taggable-fields .item", count: 3

    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."

    within(".tags") do
      expect(page).to have_link count: 3
      expect(page).to have_link "Say \"hi\""
      expect(page).to have_link "It's fine"
      expect(page).to have_link "Economía"
    end
  end

  scenario "Only the tags field is available to assistive technologies" do
    login_as(create(:user))

    visit new_debate_path

    expect(page).to have_field "Tags"
    expect(find("#debate_tag_list", visible: :all)["aria-hidden"]).to eq "true"
  end

  scenario "Tags field works after going back to the form" do
    debate = create(:debate, tag_list: "Economía")

    login_as(debate.author)
    visit edit_debate_path(debate)
    fill_in_tag_list "Hacienda"
    click_link "View debate"

    expect(page).to have_css "h1", exact_text: debate.title

    go_back

    expect(page).to have_css ".taggable-fields .ts-wrapper", count: 1
    expect(page).to have_css ".taggable-fields .item", count: 2
    expect(find_field("Tags")["aria-labelledby"]).to eq find("label", exact_text: "Tags")[:id]

    fill_in_tag_list "Impuestos"
    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."

    within(".tags") do
      expect(page).to have_link "Economía"
      expect(page).to have_link "Hacienda"
      expect(page).to have_link "Impuestos"
    end
  end

  scenario "Update" do
    debate = create(:debate, tag_list: "Economía")

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_css ".taggable-fields .item[data-value='Economía']"

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
end
