require "rails_helper"

describe "Poster" do
  let!(:proposal) { create(:proposal, :draft) }

  before do
    login_as(proposal.author)
    visit new_proposal_dashboard_poster_path(proposal)
  end

  scenario "Has a link to preview the poster" do
    expect(page).to have_link("Preview")
  end

  scenario "Has a link to download the poster" do
    expect(page).to have_link("Download")
  end

  scenario "Preview contains the proposal details" do
    click_link "Preview"

    expect(page).to have_content(proposal.title)
    expect(page).to have_content(proposal.code)
  end

  scenario "Preview page can download the poster as well" do
    click_link "Preview"

    expect(page).not_to have_link("Preview")
    expect(page).to have_link("Download")
  end

  scenario "PDF contains the proposal details" do
    within_window(window_opened_by { click_link "Download" }) do
      expect(page).to have_content(proposal.title)
      expect(page).to have_content(proposal.code)
    end
  end
end
