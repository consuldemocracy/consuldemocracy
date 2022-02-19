require "rails_helper"

describe "BudgetPolls", :with_frozen_time do
  let(:budget) { create(:budget, :balloting) }
  let(:investment) { create(:budget_investment, :selected, budget: budget) }
  let(:poll) { create(:poll, :current, budget: budget) }
  let(:booth) { create(:poll_booth) }
  let(:officer) { create(:poll_officer) }
  let(:admin) { create(:administrator) }
  let!(:user) { create(:user, :in_census) }

  before do
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
    create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth, date: Date.current)
  end

  context "Offline" do
    scenario "A citizen can cast a paper vote" do
      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
        expect(page).not_to have_button("Confirm vote")
        expect(page).to have_content "Vote introduced!"
      end

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("booth")

      visit root_path
      click_link "Sign out"
      login_as(admin.user)
      visit admin_poll_recounts_path(poll)

      within("#total_system") do
        expect(page).to have_content "1"
      end

      within "tr", text: booth.name do
        expect(page).to have_content "1"
      end
    end

    scenario "A citizen cannot vote offline again" do
      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")

        expect(page).to have_content "Vote introduced"
      end

      visit new_officing_residence_path
      officing_verify_residence

      within("#poll_#{poll.id}") do
        expect(page).to have_content "Has already participated in this poll"
      end
    end

    scenario "A citizen cannot vote online after voting offline" do
      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
      end

      expect(page).to have_content "Vote introduced!"

      login_as(user)

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        click_button "Vote"

        expect(page).to have_content "You have already participated offline"
        expect(page).not_to have_button "Vote", disabled: :all
      end
    end
  end

  context "Online" do
    scenario "A citizen can cast vote online" do
      login_as(user)
      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        click_button "Vote"
        expect(page).to have_content "Remove"
      end
    end

    scenario "A citizen cannot vote online again" do
      login_as(user)
      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        click_button "Vote"
        expect(page).to have_content "Remove"
      end

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        expect(page).to have_content "Remove vote"
      end
    end

    scenario "A citizen cannot vote offline after voting online" do
      login_as(user)
      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        click_button "Vote"
        expect(page).to have_content "Remove"
      end

      logout
      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      within("#poll_#{poll.id}") do
        expect(page).not_to have_button("Confirm vote")
        expect(page).to have_content("Has already participated in this poll")
      end
    end
  end
end
