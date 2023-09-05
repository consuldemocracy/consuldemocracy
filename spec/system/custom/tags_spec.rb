require "rails_helper"

describe "Tags" do
  scenario "Create" do
    user = create(:user)
    login_as(user)

    visit new_debate_path
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"

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
    fill_in_new_debate_title with: "Title"
    fill_in_ckeditor "Initial debate text", with: "Description"

    fill_in "debate_tag_list", with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button "Start a debate"

    expect(page).to have_content error_message
    expect(page).to have_content "tags must be less than or equal to 6"
  end
end
