require "rails_helper"

describe "Valuation budget investments" do

  let(:budget) { create(:budget) }
  let(:tracker) do
    create(:tracker, user: create(:user, username: "Rachel", email: "rachel@trackers.org"))
  end

  before do
    login_as(tracker.user)
  end

  scenario "Disabled with a feature flag" do
    Setting["process.budgets"] = nil
    expect {
      visit tracking_budget_budget_investments_path(create(:budget))
    }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario "Display link to tracking section" do
    visit root_path
    expect(page).to have_link "Tracking", href: tracking_root_path
  end

  describe "Index" do
    scenario "Index shows budget investments assigned to current tracker" do
      investment1 = create(:budget_investment, budget: budget)
      investment2 = create(:budget_investment, budget: budget)

      investment1.trackers << tracker

      visit tracking_budget_budget_investments_path(budget)

      expect(page).to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    scenario "Index shows no budget investment to admins no trackers" do
      investment1 = create(:budget_investment, budget: budget)
      investment2 = create(:budget_investment, budget: budget)

      investment1.trackers << tracker

      logout
      login_as create(:administrator).user
      visit tracking_budget_budget_investments_path(budget)

      expect(page).not_to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    scenario "Index displays investments paginated" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times do
        investment = create(:budget_investment, budget: budget)
        investment.trackers << tracker
      end

      visit tracking_budget_budget_investments_path(budget)

      expect(page).to have_css(".budget_investment", count: per_page)
      within("ul.pagination") do
        expect(page).to have_content("1")
        expect(page).to have_content("2")
        expect(page).not_to have_content("3")
        click_link "Next", exact: false
      end

      expect(page).to have_css(".budget_investment", count: 2)
    end

    scenario "headings" do
      investment1 = create(:budget_investment,
                           budget: budget,
                           title: "investment 1",
                           heading: create(:budget_heading, name: "first_heading"))
      investment2 = create(:budget_investment,
                           budget: budget, title: "investment 2",
                           heading: create(:budget_heading, name: "last_heading"))
      create(:budget_investment,
                           budget: budget,
                           title: "investment 3",
                           heading: create(:budget_heading, name: "no_heading"))

      investment1.trackers << tracker
      investment2.trackers << tracker

      visit tracking_budget_budget_investments_path(budget)

      expect(page).to have_link("All headings (2)")
      expect(page).to have_link("last_heading (1)")
      expect(page).to have_link("first_heading (1)")
      expect(page).not_to have_link("no_heading (1)")

      expect(page).to have_content("investment 1")
      expect(page).to have_content("investment 2")
      expect(page).not_to have_content("investment 3")

      expect(page.find(".select-heading .is-active")).to have_content("All headings")

      click_on "last_heading (1)"

      expect(page.find(".select-heading .is-active")).to have_content("last_heading (1)")
      expect(page).not_to have_content("investment 1")
      expect(page).to have_content("investment 2")
      expect(page).not_to have_content("investment 3")
    end
  end

  describe "Show" do
    let(:administrator) do
      create(:administrator, user: create(:user, username: "Ana", email: "ana@admins.org"))
    end
    let(:second_tracker) do
      create(:tracker, user: create(:user, username: "Rick", email: "rick@trackers.org"))
    end
    let(:investment) do
      create(:budget_investment, budget: budget, administrator: administrator)
    end

    before do
      investment.trackers << [tracker, second_tracker]
    end

    scenario "visible for assigned trackers" do
      visit tracking_budget_budget_investments_path(budget)

      click_link investment.title

      expect(page).to have_content(investment.title)
      expect(page).to have_content(investment.description)
      expect(page).to have_content(investment.author.name)
      expect(page).to have_content(investment.heading.name)

      within("#assigned_trackers") do
        expect(page).to have_content("Rachel (rachel@trackers.org)")
        expect(page).to have_content("Rick (rick@trackers.org)")
      end
    end

    scenario "visible for admins" do
      logout
      login_as create(:administrator).user

      visit tracking_budget_budget_investment_path(budget, investment)

      expect(page).to have_content(investment.title)
      expect(page).to have_content(investment.description)
      expect(page).to have_content(investment.author.name)
      expect(page).to have_content(investment.heading.name)
      expect(page).to have_content("Ana (ana@admins.org)")

      within("#assigned_trackers") do
        expect(page).to have_content("Rachel (rachel@trackers.org)")
        expect(page).to have_content("Rick (rick@trackers.org)")
      end
    end

    scenario "not visible for not assigned trackers" do
      logout
      login_as create(:tracker).user

      expect {
        visit tracking_budget_budget_investment_path(budget, investment)
      }.to raise_error "Not Found"
    end

  end

  describe "Milestones" do
    let(:admin) { create(:administrator) }
    let(:investment) do
      heading = create(:budget_heading)
      create(:budget_investment, heading: heading, budget: budget,
                                 administrator: admin)
    end

    before do
      investment.trackers << tracker
    end

    scenario "visit investment manage milestones" do

      visit tracking_budget_budget_investments_path(budget)

      click_link "Edit milestones"

      expect(page).to have_content("Milestone")
      expect(page).to have_content(investment.title)
    end

    scenario "create investment milestones" do
      visit edit_tracking_budget_budget_investment_path(budget, investment)

      expect(page).to have_content("Milestone")
      expect(page).to have_content(investment.title)

      click_link "Create new milestone"

      expect(page).to have_content("Create milestone")
      fill_in("Description", with: "Test Description")
      page.find("#milestone_publication_date").set(Date.current)

      click_button "Create milestone"

      visit edit_tracking_budget_budget_investment_path(budget, investment)

      expect(page).to have_content("Test Description")
    end

    scenario "delete investment milestones" do
      milestone = create(:milestone,
                         milestoneable: investment,
                         description: "Test delete milestone")

      visit edit_tracking_budget_budget_investment_path(budget, investment)

      expect(page).to have_content("Test delete milestone")

      page.find("#milestone_#{milestone.id}").click_link("Delete milestone")

      visit edit_tracking_budget_budget_investment_path(budget, investment)

      expect(page).not_to have_content("Test delete milestone")

    end

    scenario "edit investment milestones" do
      milestone = create(:milestone, milestoneable: investment, description: "Test edit milestone")

      visit edit_tracking_budget_budget_investment_path(budget, investment)

      expect(page).to have_content("Test edit milestone")

      page.find("#milestone_#{milestone.id}").first("a").click

      expect(page).to have_content("Edit milestone")
      expect(page).to have_content("Test edit milestone")
      fill_in("Description", with: "Test edited milestone")

      click_button "Update milestone"

      visit edit_tracking_budget_budget_investment_path(budget, investment)

      expect(page).not_to have_content("Test edit milestone")
      expect(page).to have_content("Test edited milestone")

    end

  end

  describe "Progress Bars" do

    let(:admin) { create(:administrator) }
    let(:investment) do
      heading = create(:budget_heading)
      create(:budget_investment, heading: heading, budget: budget,
             administrator: admin)
    end

    before do
      investment.trackers << tracker
    end

    scenario "view index" do
      visit edit_tracking_budget_budget_investment_path(budget, investment)

      click_link "Manage progress bars"

      expect(page).to have_content("Progress bars")

      logout
      login_as create(:tracker, user: create(:user)).user

      expect {
        visit tracking_budget_budget_investment_progress_bars_path(budget, investment)
      }.to raise_error "Not Found"
    end

    scenario "create primary progress bar" do

      visit tracking_budget_budget_investment_progress_bars_path(budget, investment)

      expect(page).to have_content("Progress bars")

      click_link "Create new progress bar"

      expect(page).to have_content("Create progress bar")

      select("Primary", :from => "Type")
      fill_in("Current progress", :with => 50)

      click_button "Create Progress bar"

      expect(page).to have_content("Progress bars")

      expect(page).to have_content("Primary")
    end

    scenario "create secondary progress bar" do

      visit tracking_budget_budget_investment_progress_bars_path(budget, investment)

      expect(page).to have_content("Progress bars")

      click_link "Create new progress bar"

      expect(page).to have_content("Create progress bar")

      select("Secondary", :from => "Type")
      fill_in("Title", :with => "secondary_progress_bar")
      fill_in("Current progress", :with => 50)

      click_button "Create Progress bar"

      expect(page).to have_content("Progress bars")

      expect(page).to have_content("secondary_progress_bar")
    end

    scenario "delete" do
      create(:progress_bar, progressable: investment)
      secondary_progress_bar = create(:progress_bar,
                                      :secondary,
                                      title: "to delete",
                                      progressable: investment)

      visit tracking_budget_budget_investment_progress_bars_path(budget, investment)

      expect(page).to have_content("Primary")
      expect(page).to have_content(secondary_progress_bar.title)

      page.find("#progress_bar_#{secondary_progress_bar.id}").click_link("Delete")

      visit tracking_budget_budget_investment_progress_bars_path(budget, investment)

      expect(page).to have_content("Primary")
      expect(page).not_to have_content(secondary_progress_bar.title)
    end

    scenario "edit" do
      create(:progress_bar, progressable: investment)
      secondary_progress_bar = create(:progress_bar,
                                      :secondary,
                                      title: "to edit",
                                      progressable: investment)

      visit tracking_budget_budget_investment_progress_bars_path(budget, investment)

      expect(page).to have_content("Primary")
      expect(page).to have_content(secondary_progress_bar.title)

      page.find("#progress_bar_#{secondary_progress_bar.id}").click_link("Edit")

      fill_in("Title", :with => "edited")
      click_button "Update Progress bar"

      expect(page).to have_content("Progress bars")

      expect(page).to have_content("edited")
    end

  end
end
