require "rails_helper"

describe "Classification suggestions" do
  before do
    Setting["llm.provider"] = "OpenAI"
    Setting["llm.model"] = "gpt-4o"
    Setting["llm.use_ai_classification_suggestions"] = true
    Setting["feature.sdg"] = false
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

  scenario "shows an empty tags message when there are no suggestions" do
    llm_response = ClassificationSuggestions::Llm::Client::Response.new
    allow(ClassificationSuggestions::Llm::Client).to receive(:call).and_return(llm_response)

    login_as(create(:user))
    visit new_debate_path

    fill_in "Debate title", with: "More green spaces"
    fill_in_ckeditor "Initial debate text", with: "We need parks and trees in every neighbourhood."

    click_button "Suggest tags"

    within ".classification-suggestions-tags" do
      expect(page).to have_css ".callout.primary[role='status']",
                               text: "No category or tag suggestions for this draft."
    end
  end

  scenario "shows a tag list full error when the list already has six tags" do
    login_as(create(:user))
    visit new_debate_path

    fill_in "Debate title", with: "More green spaces"
    fill_in_ckeditor "Initial debate text", with: "We need parks and trees in every neighbourhood."
    fill_in_tag_list "one, two, three, four, five, six"

    click_button "Suggest tags"

    within ".classification-suggestions-tags" do
      expect(page).to have_css ".callout.alert[role='alert']",
                               text: "You have already added the maximum of 6 tags. " \
                                     "Remove some to make room for new suggestions."
    end
  end

  scenario "shows an inline notice when applying a suggestion would exceed six tags" do
    llm_response = ClassificationSuggestions::Llm::Client::Response.new.tap do |response|
      response.tags = %w[parks trees]
    end
    allow(ClassificationSuggestions::Llm::Client).to receive(:call).and_return(llm_response)

    login_as(create(:user))
    visit new_debate_path

    fill_in "Debate title", with: "More green spaces"
    fill_in_ckeditor "Initial debate text", with: "We need parks and trees in every neighbourhood."
    fill_in_tag_list "one, two, three, four, five"

    click_button "Suggest tags"

    expect(page).to have_button "parks"
    expect(page).to have_button "trees"

    click_button "parks"

    expect(page).to have_css ".item[data-value='parks']"
    expect(page).not_to have_button "parks"
    expect(page).to have_button "trees"

    click_button "trees"

    expect(page).to have_css ".classification-suggestions-notice.callout.alert[role='alert']",
                             text: "You have already added the maximum of 6 tags. " \
                                   "Remove some to make room for new suggestions."
    expect(page).to have_button "trees"
    expect(page).not_to have_css ".item[data-value='trees']"
    expect(page).to have_css ".taggable-fields .item", count: 6

    remove_tag_list_tag "parks"

    expect(page).not_to have_css ".classification-suggestions-notice"
    expect(page).to have_button "trees"

    click_button "trees"

    expect(page).to have_css ".item[data-value='trees']"
    expect(page).not_to have_button "trees"
  end

  scenario "stops Accept all at the tag limit and keeps remaining suggestions" do
    llm_response = ClassificationSuggestions::Llm::Client::Response.new.tap do |response|
      response.tags = %w[parks trees]
    end
    allow(ClassificationSuggestions::Llm::Client).to receive(:call).and_return(llm_response)

    login_as(create(:user))
    visit new_debate_path

    fill_in "Debate title", with: "More green spaces"
    fill_in_ckeditor "Initial debate text", with: "We need parks and trees in every neighbourhood."
    fill_in_tag_list "one, two, three, four, five"

    click_button "Suggest tags"

    within ".classification-suggestions-tags" do
      click_button "Accept all"
    end

    expect(page).to have_css ".item[data-value='parks']"
    expect(page).not_to have_css ".item[data-value='trees']"
    expect(page).to have_css ".taggable-fields .item", count: 6
    expect(page).to have_css ".classification-suggestions-notice.callout.alert[role='alert']",
                             text: "You have already added the maximum of 6 tags. " \
                                   "Remove some to make room for new suggestions."
    expect(page).to have_button "trees"
  end
end
