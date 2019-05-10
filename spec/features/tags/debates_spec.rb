require "rails_helper"

feature "Tags" do

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

  scenario "Index shows up to 5 tags per proposal" do
    tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
    create :debate, tag_list: tag_list

    visit debates_path

    within(".debate .tags") do
      expect(page).to have_content "1+"
    end
  end

  scenario "Index shows 3 tags with no plus link" do
    tag_list = ["Medio Ambiente", "Corrupción", "Fiestas populares"]
    create :debate, tag_list: tag_list

    visit debates_path

    within(".debate .tags") do
      tag_list.each do |tag|
        expect(page).to have_content tag
      end
      expect(page).not_to have_content "+"
    end
  end

  scenario "Index tag does not show featured debates" do
    featured_debates = create_featured_debates
    debates = create(:debate, tag_list: "123")

    visit debates_path(tag: "123")

    expect(page).not_to have_selector("#debates .debate-featured")
    expect(page).not_to have_selector("#featured-debates")
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
    fill_in "debate_title", with: "Title"
    fill_in "debate_description", with: "Description"
    check "debate_terms_of_service"

    fill_in "debate_tag_list", with: "Impuestos, Economía, Hacienda"

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
    fill_in "debate_title", with: "Title"
    fill_in "debate_description", with: "Description"
    check "debate_terms_of_service"

    fill_in "debate_tag_list", with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button "Start a debate"

    expect(page).to have_content error_message
    expect(page).to have_content "tags must be less than or equal to 6"
  end

  scenario "Create with dangerous strings" do
    user = create(:user)
    login_as(user)

    visit new_debate_path

    fill_in "debate_title", with: "A test of dangerous strings"
    fill_in "debate_description", with: "A description suitable for this test"
    check "debate_terms_of_service"

    fill_in "debate_tag_list", with: "user_id=1, &a=3, <script>alert('hey');</script>"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_content "user_id1"
    expect(page).to have_content "a3"
    expect(page).to have_content "scriptalert('hey');script"
    expect(page.html).not_to include "user_id=1, &a=3, <script>alert('hey');</script>"
  end

  scenario "Update" do
    debate = create(:debate, tag_list: "Economía")

    login_as(debate.author)
    visit edit_debate_path(debate)

    expect(page).to have_selector("input[value='Economía']")

    fill_in "debate_tag_list", with: "Economía, Hacienda"
    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."
    within(".tags") do
      expect(page).to have_css("a", text: "Economía")
      expect(page).to have_css("a", text: "Hacienda")
    end
  end

  scenario "Delete" do
    debate = create(:debate, tag_list: "Economía")

    login_as(debate.author)
    visit edit_debate_path(debate)

    fill_in "debate_tag_list", with: ""
    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."
    expect(page).not_to have_content "Economía"
  end

  context "Filter" do

    scenario "From index" do
      debate1 = create(:debate, tag_list: "Education")
      debate2 = create(:debate, tag_list: "Health")

      visit debates_path

      within "#debate_#{debate1.id}" do
        click_link "Education"
      end

      within("#debates") do
        expect(page).to have_css(".debate", count: 1)
        expect(page).to have_content(debate1.title)
      end
    end

    scenario "From show" do
      debate1 = create(:debate, tag_list: "Education")
      debate2 = create(:debate, tag_list: "Health")

      visit debate_path(debate1)

      click_link "Education"

      within("#debates") do
        expect(page).to have_css(".debate", count: 1)
        expect(page).to have_content(debate1.title)
      end
    end

  end

  context "Tag cloud" do

    scenario "Display user tags" do
      earth = create(:debate, tag_list: "Medio Ambiente")
      money = create(:debate, tag_list: "Economía")

      visit debates_path

      within "#tag-cloud" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "Filter by user tags" do
      debate1 = create(:debate, tag_list: "Medio Ambiente")
      debate2 = create(:debate, tag_list: "Medio Ambiente")
      debate3 = create(:debate, tag_list: "Economía")

      visit debates_path

      within "#tag-cloud" do
        click_link "Medio Ambiente"
      end

      expect(page).to have_css ".debate", count: 2
      expect(page).to have_content debate1.title
      expect(page).to have_content debate2.title
      expect(page).not_to have_content debate3.title
    end

  end
end
