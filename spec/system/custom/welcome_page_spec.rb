require "rails_helper"

describe "Welcome page" do
  context "Feeds" do
    scenario "Show message if there are no items" do
      visit root_path

      within "#feed_proposals" do
        expect(page).to have_content "There are no proposals right now"
      end

      within "#feed_debates" do
        expect(page).to have_content "There are no debates right now"
      end

      within "#feed_budgets" do
        expect(page).to have_content "There are no budgets right now"
      end

      within "#feed_processes" do
        expect(page).to have_content "There are no open processes right now"
      end
    end

    scenario "Show published budgets info" do
      budget = create(:budget, :accepting)
      finished = create(:budget, :finished)
      group = create(:budget_group, budget: finished)
      create(:budget_heading, group: group, price: 10000)
      hide_money = create(:budget, :valuating, :hide_money)
      draft = create(:budget, :drafting)
      draft.current_phase.update!(description: "Budget in draft mode")

      visit root_path

      within "#feed_budgets" do
        expect(page).to have_content budget.name
        expect(page).to have_content budget.formatted_total_headings_price
        expect(page).to have_content budget.current_phase.name
        expect(page).to have_content "#{budget.current_enabled_phase_number}/#{budget.enabled_phases_amount}"
        expect(page).to have_content budget.current_phase.starts_at.to_date.to_s
        expect(page).to have_content (budget.current_phase.ends_at.to_date - 1.day).to_s
        expect(page).to have_content budget.description
        expect(page).to have_content "See this budget", count: 3
        expect(page).to have_link href: budget_path(budget)
        expect(page).to have_content finished.name
        expect(page).to have_content finished.formatted_total_headings_price
        expect(page).to have_content "COMPLETED"
        expect(page).to have_content "€", count: 1
        expect(page).to have_content finished.current_phase.starts_at.to_date.to_s
        expect(page).to have_content (finished.current_phase.ends_at.to_date - 1.day).to_s
        expect(page).to have_content finished.description
        expect(page).to have_link href: budget_path(finished)
        expect(page).not_to have_content draft.name
        expect(page).not_to have_content draft.description
        expect(page).not_to have_link href: budget_path(draft)
        expect(page).to have_content hide_money.name
        expect(page).to have_content hide_money.current_phase.starts_at.to_date.to_s
        expect(page).to have_content (hide_money.current_phase.ends_at.to_date - 1.day).to_s
        expect(page).to have_content hide_money.description
        expect(page).to have_link href: budget_path(hide_money)
      end
    end
  end

  scenario "Show three steps section only if feature is enabled" do
    Setting["feature.welcome_steps"] = false

    visit root_path

    expect(page).not_to have_selector "#home_page_steps"

    Setting["feature.welcome_steps"] = true

    visit root_path

    within "#home_page_steps" do
      expect(page).to have_content "1"
      expect(page).to have_content "Sign-up"
      expect(page).to have_content "Short text describing some of the data that is expected to be "\
                                   "asked when making an account."
      expect(page).to have_link "Make an account in 5 minutes"
      expect(page).to have_content "2"
      expect(page).to have_content "Decide"
      expect(page).to have_content "Share your ideas and vote on the changes you want to see in the city."
      expect(page).to have_link "See what's happening around the city right now"
      expect(page).to have_content "3"
      expect(page).to have_content "Share"
      expect(page).to have_content "Keep up with the ideas that matter to you the most, and share them "\
                                   "through social media."
      expect(page).to have_link "Another optional call to action"
    end
  end

  scenario "Show footer logo image only if feature is enabled" do
    Setting["feature.logo_image_footer"] = false

    visit root_path

    expect(page).not_to have_selector "#logo_footer"

    Setting["feature.logo_image_footer"] = true

    visit root_path

    within "#logo_footer" do
      expect(page).to have_css("img[alt=\"\"]")
    end
  end

  scenario "Show footer background image only if feature is enabled" do
    Setting["feature.background_image_footer"] = false

    visit root_path

    expect(page).not_to have_selector "#bg_footer"

    Setting["feature.background_image_footer"] = true

    visit root_path

    within "#bg_footer" do
      expect(page).to have_css("img[alt=\"\"]")
    end
  end
end
