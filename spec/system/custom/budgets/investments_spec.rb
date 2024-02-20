require "rails_helper"
require "sessions_helper"

describe "Budget Investments" do
  let(:author)  { create(:user, :level_two, username: "Isabel") }
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:other_budget) { create(:budget, name: "What a Budget!") }
  let(:group) { create(:budget_group, name: "Health", budget: budget) }
  let!(:heading) { create(:budget_heading, name: "More hospitals", price: 666666, group: group) }

  scenario "Can visit an investment from image link" do
    investment = create(:budget_investment, :with_image, heading: heading)

    visit budget_investments_path(budget, heading_id: heading.id)

    within("#budget_investment_#{investment.id}") do
      find("#image").click
    end

    expect(page).to have_current_path(budget_investment_path(budget, id: investment.id))
  end

  context("Filters") do
    context "Results Phase" do
      before { budget.update(phase: "finished", results_enabled: true) }

      scenario "show winners by default" do
        investment1 = create(:budget_investment, :winner, heading: heading)
        investment2 = create(:budget_investment, :selected, heading: heading)

        visit budget_investments_path(budget, heading_id: heading)

        within("#budget-investments") do
          expect(page).to have_css(".budget-investment", count: 1)
          expect(page).to have_content(investment1.title)
          expect(page).not_to have_content(investment2.title)
        end

        visit budget_results_path(budget)
        click_link "See all investments"

        within("#budget-investments") do
          expect(page).to have_css(".budget-investment", count: 1)
          expect(page).to have_content(investment1.title)
          expect(page).not_to have_content(investment2.title)
        end
      end
    end
  end

  context "Phase I - Accepting" do
    before { budget.update(phase: "accepting") }

    scenario "Create with invisible_captcha honeypot field", :no_js do
      login_as(author)
      visit new_budget_investment_path(budget)

      fill_in "Title", with: "I am a bot"
      fill_in "budget_investment_subtitle", with: "This is the honeypot"
      fill_in "Description", with: "This is the description"

      click_button "Create Investment"

      expect(page.status_code).to eq(200)
      expect(page.html).to be_empty
      expect(page).to have_current_path(budget_investments_path(budget))
    end

    scenario "Create budget investment too fast" do
      allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

      login_as(author)
      visit new_budget_investment_path(budget)

      fill_in_new_investment_title with: "I am a bot"
      fill_in_ckeditor "Description", with: "This is the description"

      click_button "Create Investment"

      expect(page).to have_content "Sorry, that was too quick! Please resubmit"
      expect(page).to have_current_path(new_budget_investment_path(budget))
    end

    scenario "Create with single heading" do
      login_as(author)

      visit new_budget_investment_path(budget)

      expect(page).not_to have_field "budget_investment_heading_id"
      expect(page).to have_content("#{heading.name} (#{budget.formatted_heading_price(heading)})")

      fill_in "Title", with: "Build a skyscraper"
      fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
      fill_in "Information about the location", with: "City center"
      fill_in "If you are proposing in the name of a collective/organization, "\
              "or on behalf of more people, write its name", with: "T.I.A."
      fill_in "Tags", with: "Towers"

      click_button "Create Investment"

      expect(page).to have_content "Investment created successfully"
      expect(page).to have_content "Build a skyscraper"
      expect(page).to have_content "I want to live in a high tower over the clouds"
      expect(page).to have_content "City center"
      expect(page).to have_content "T.I.A."
      expect(page).to have_content "Towers"

      visit user_path(author, filter: :budget_investments)

      expect(page).to have_content "1 Investment"
      expect(page).to have_content "Build a skyscraper"
    end

    scenario "Create with multiple headings" do
      heading2 = create(:budget_heading, budget: budget, group: group)
      heading3 = create(:budget_heading, budget: budget)
      login_as(author)

      visit new_budget_investment_path(budget)

      expect(page).not_to have_content("#{heading.name} (#{budget.formatted_heading_price(heading)})")

      within("#budget_investment_heading_id") do
        expect(page).to have_selector("option[value='#{heading.id}']")
        expect(page).to have_selector("option[value='#{heading2.id}']")
        expect(page).to have_selector("option[value='#{heading3.id}']")
      end

      select "#{group.name}: #{heading2.name}", from: "budget_investment_heading_id"
      fill_in "Title", with: "Build a skyscraper"
      fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
      fill_in "budget_investment_location", with: "City center"
      fill_in "budget_investment_organization_name", with: "T.I.A."
      fill_in "budget_investment_tag_list", with: "Towers"

      click_button "Create Investment"

      expect(page).to have_content "Investment created successfully"
      expect(page).to have_content "Build a skyscraper"
      expect(page).to have_content "I want to live in a high tower over the clouds"
      expect(page).to have_content "City center"
      expect(page).to have_content "T.I.A."
      expect(page).to have_content "Towers"

      visit user_path(author, filter: :budget_investments)

      expect(page).to have_content "1 Investment"
      expect(page).to have_content "Build a skyscraper"
    end

    scenario "Create with multiple groups" do
      education = create(:budget_group, budget: budget, name: "Education")

      create(:budget_heading, group: group, name: "Medical supplies")
      create(:budget_heading, group: education, name: "Schools")

      login_as(author)

      visit new_budget_investment_path(budget)

      expect(page).not_to have_content("#{heading.name} (#{budget.formatted_heading_price(heading)})")
      expect(page).to have_select "Heading",
        options: ["", "Health: More hospitals", "Health: Medical supplies", "Education: Schools"]

      select "Health: Medical supplies", from: "Heading"

      fill_in_new_investment_title with: "Build a skyscraper"
      fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
      fill_in "Information about the location", with: "City center"
      fill_in "If you are proposing in the name of a collective/organization, "\
              "or on behalf of more people, write its name", with: "T.I.A."
      fill_in "Tags", with: "Towers"

      click_button "Create Investment"

      expect(page).to have_content "Investment created successfully"
      expect(page).to have_content "Build a skyscraper"
      expect(page).to have_content "I want to live in a high tower over the clouds"
      expect(page).to have_content "City center"
      expect(page).to have_content "T.I.A."
      expect(page).to have_content "Towers"

      visit user_path(author, filter: :budget_investments)

      expect(page).to have_content "1 Investment"
      expect(page).to have_content "Build a skyscraper"
    end
  end

  scenario "Show" do
    investment = create(:budget_investment, heading: heading)

    user = create(:user)
    login_as(user)

    visit budget_investment_path(budget, id: investment.id)

    expect(page).to have_content(investment.title)
    expect(page).to have_content(investment.description)
    expect(page).to have_content(investment.author.name)
    expect(page).to have_content(investment.comments_count)
    expect(page).to have_content(investment.heading.name)
  end

  scenario "Show feasible explanation only when valuation finished" do
    investment = create(:budget_investment, :feasible, budget: budget, heading: heading,
                        feasibility_explanation: "Local government is competent in this")

    investment_2 = create(:budget_investment, :feasible, :finished, budget: budget, heading: heading,
                          feasibility_explanation: "The feasible explanation")

    user = create(:user)
    login_as(user)

    visit budget_investment_path(budget, investment)

    expect(page).not_to have_content("Feasibility explanation")
    expect(page).not_to have_content("Local government is competent in this")

    visit budget_investment_path(budget, investment_2)

    expect(page).to have_content("Feasibility explanation")
    expect(page).to have_content("The feasible explanation")
  end

  context "Balloting Phase" do
    before do
      budget.update(phase: "balloting")
    end

    scenario "Confirm" do
      budget.update!(phase: "balloting")
      budget.phases.balloting.update!(starts_at: "01-10-2020", ends_at: "31-12-2020")
      user = create(:user, :level_two)

      global_group   = create(:budget_group, budget: budget, name: "Global Group")
      global_heading = create(:budget_heading, group: global_group, name: "Global Heading",
                              latitude: -43.145412, longitude: 12.009423)

      carabanchel_heading = create(:budget_heading, group: group, name: "Carabanchel")
      new_york_heading    = create(:budget_heading, group: group, name: "New York",
                                   latitude: -43.223412, longitude: 12.009423)

      create(:budget_investment, :selected, price: 1, heading: global_heading, title: "World T-Shirt")
      create(:budget_investment, :selected, price: 10, heading: global_heading, title: "Eco pens")
      create(:budget_investment, :selected, price: 100, heading: global_heading, title: "Free tablet")
      create(:budget_investment, :selected, price: 1000, heading: carabanchel_heading, title: "Fireworks")
      create(:budget_investment, :selected, price: 10000, heading: carabanchel_heading, title: "Bus pass")
      create(:budget_investment, :selected, price: 100000, heading: new_york_heading, title: "NASA base")

      login_as(user)
      visit budget_investments_path(budget, heading: global_heading)

      add_to_ballot("World T-Shirt")
      add_to_ballot("Eco pens")

      visit budget_investments_path(budget, heading: carabanchel_heading)

      add_to_ballot("Fireworks")
      add_to_ballot("Bus pass")

      expect(page).to have_content "You can"
      expect(page).to have_link "change your vote", href: budget_ballot_path(budget)
      expect(page).to have_content "at any time until December 31, 2020. "\
                                   "No need to spend all the money available."

      visit budget_ballot_path(budget)

      expect(page).to have_content "But you can change your vote at any time "\
                                   "until this phase is closed."

      within("#budget_group_#{global_group.id}") do
        expect(page).to have_content "World T-Shirt"
        expect(page).to have_content "€1"

        expect(page).to have_content "Eco pens"
        expect(page).to have_content "€10"

        expect(page).not_to have_content "Free tablet"
        expect(page).not_to have_content "€100"
      end

      within("#budget_group_#{group.id}") do
        expect(page).to have_content "Fireworks"
        expect(page).to have_content "€1,000"

        expect(page).to have_content "Bus pass"
        expect(page).to have_content "€10,000"

        expect(page).not_to have_content "NASA base"
        expect(page).not_to have_content "€100,000"
      end
    end
  end

  context "sidebar map" do
    context "Author actions section" do
      scenario "Do not show edit button in phases different from accepting" do
        budget.update!(phase: "reviewing")
        investment = create(:budget_investment, :with_image, heading: heading, author: author)

        login_as(author)
        visit budget_investment_path(budget, investment)

        within("aside") do
          expect(page).not_to have_content "AUTHOR"
          expect(page).not_to have_link "Edit"
        end
      end
    end
  end

  describe "SDG related list" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.budgets"] = true
      budget.update!(phase: "accepting")
    end

    scenario "create budget investment with sdg related list" do
      login_as(author)
      visit new_budget_investment_path(budget)
      fill_in_new_investment_title with: "A title for a budget investment related with SDG related content"
      fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
      click_sdg_goal(1)

      click_button "Create Investment"

      within(".sdg-goal-tag-list") { expect(page).to have_link "1. No Poverty" }
    end
  end
end
