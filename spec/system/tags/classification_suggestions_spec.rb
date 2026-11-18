require "rails_helper"

describe "Classification suggestions" do
  before do
    Setting["llm.provider"] = "OpenAI"
    Setting["llm.model"] = "gpt-4o"
    Setting["llm.use_ai_classification_suggestions"] = true
  end

  scenario "restores a suggested tag after it is removed from the list" do
    llm_response = ClassificationSuggestions::Llm::Client::Response.new.tap do |response|
      response.tags = ["parks"]
    end
    allow(ClassificationSuggestions::Llm::Client).to receive(:call).and_return(llm_response)

    login_as(create(:user))
    visit new_debate_path

    fill_in "Debate title", with: "More green spaces"
    fill_in_ckeditor "Initial debate text", with: "We need parks and trees in every neighbourhood."

    click_button "Suggest tags"

    expect(page).to have_css ".classification-suggestions-tags"
    expect(page).to have_button "parks"

    click_button "parks"

    expect(page).to have_css ".item[data-value='parks']"
    expect(page).not_to have_button "parks"

    remove_tag_list_tag "parks"

    expect(page).not_to have_css ".item[data-value='parks']"
    expect(page).to have_css ".classification-suggestions-tags"
    expect(page).to have_button "parks"
  end

  scenario "hides a suggested category when selected from the category list" do
    create(:tag, :category, name: "Sustainability")

    llm_response = ClassificationSuggestions::Llm::Client::Response.new.tap do |response|
      response.categories = ["Sustainability"]
      response.tags = ["parks"]
    end
    allow(ClassificationSuggestions::Llm::Client).to receive(:call).and_return(llm_response)

    login_as(create(:user))
    visit new_debate_path

    fill_in "Debate title", with: "More green spaces"
    fill_in_ckeditor "Initial debate text", with: "We need parks and trees in every neighbourhood."

    click_button "Suggest tags"

    expect(page).to have_button "Sustainability"
    expect(page).to have_button "parks"

    find("label", exact_text: "Sustainability").click

    expect(page).to have_css ".item[data-value='Sustainability']"
    expect(page).to have_checked_field "Sustainability"
    expect(page).not_to have_button "Sustainability"
    expect(page).to have_button "parks"

    remove_tag_list_tag "Sustainability"

    expect(page).to have_unchecked_field "Sustainability"
    expect(page).to have_button "Sustainability"
    expect(page).to have_button "parks"
  end
end
