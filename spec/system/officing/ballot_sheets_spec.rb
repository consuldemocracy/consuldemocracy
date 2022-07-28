require "rails_helper"

describe "Officing ballot sheets" do
  let(:budget) { create(:budget, :reviewing_ballots) }
  let(:heading) { create(:budget_heading, budget: budget, price: 300) }
  let(:poll) { create(:poll, name: "Latest budget poll", budget: budget, ends_at: Date.current) }
  let(:booth) { create(:poll_booth, name: "The only booth") }
  let(:officer) { create(:poll_officer) }
  let!(:admin) { create(:administrator).user }

  scenario "Create a ballot sheet for a budget poll" do
    create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth)
    create(:poll_shift, :recount_scrutiny_task, officer: officer, booth: booth, date: Date.current)

    titles = %w[First Second Third Fourth]
    investments = 4.times.map do |n|
      create(:budget_investment, :selected, title: titles[n], heading: heading, price: 100)
    end

    login_as(officer.user)
    visit officing_root_path
    click_link "Total recounts and results"
    within("tr", text: "Latest budget poll") { click_link "Add results" }

    select "The only booth", from: "Booth"
    fill_in "CSV data", with: "#{investments[0..1].map(&:id).join(",")};#{investments[1..2].map(&:id).join(",")}"
    click_button "Save"

    expect(page).to have_content "Creation date"
    expect(page).to have_content "CSV data"

    logout
    login_as(admin)
    visit admin_budget_path(budget)
    click_button "Calculate Winner Investments"

    expect(page).to have_content "Winners being calculated"

    visit budget_results_path(budget)

    within("tr", text: "Second") { expect(page).to have_content("2") }
    within("tr", text: "First") { expect(page).to have_content("1") }
    within("tr", text: "Third") { expect(page).to have_content("1") }
    expect(page).not_to have_content "Fourth"
  end
end
