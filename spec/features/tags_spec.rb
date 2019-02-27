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

  context "Tag cloud" do

    scenario "Proposals" do
      earth = create(:proposal, tag_list: "Medio Ambiente")
      money = create(:proposal, tag_list: "Economía")

      visit proposals_path

      within "#tag-cloud" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "Debates" do
      earth = create(:debate, tag_list: "Medio Ambiente")
      money = create(:debate, tag_list: "Economía")

      visit debates_path

      within "#tag-cloud" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "scoped by category" do
      create(:tag, :category, name: "Medio Ambiente")
      create(:tag, :category, name: "Economía")

      earth = create(:proposal, tag_list: "Medio Ambiente, Agua")
      money = create(:proposal, tag_list: "Economía, Corrupción")

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

      earth = create(:proposal, tag_list: "Madrid, Agua")
      money = create(:proposal, tag_list: "Barcelona, Playa")

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
