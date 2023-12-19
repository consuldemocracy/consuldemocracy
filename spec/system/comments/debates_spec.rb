require "rails_helper"

describe "Commenting debates" do
  let(:user)   { create(:user) }
  let(:debate) { create(:debate) }

  it_behaves_like "flaggable", :debate_comment

  scenario "Submit button is disabled after clicking" do
    debate = create(:debate)
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Testing submit button!"
    click_button "Publish comment"

    expect(page).to have_button "Publish comment", disabled: true
    expect(page).to have_content "Testing submit button!"
    expect(page).to have_button "Publish comment", disabled: false
  end
end
