require "rails_helper"

describe "Budget Investments" do
  let(:manager) { create(:manager) }
  let(:budget)  { create(:budget, :selecting, name: "2033", slug: "budget_slug") }
  let(:group)   { create(:budget_group, budget: budget, name: "Whole city") }
  let(:heading) { create(:budget_heading, group: group, name: "Health") }
  let(:user)    { create(:user, :level_two) }

  it_behaves_like "nested documentable",
                  "user",
                  "budget_investment",
                  "new_management_budget_investment_path",
                  { budget_id: "budget_id" },
                  "documentable_fill_new_valid_budget_investment",
                  "Create Investment",
                  "Investment created successfully.",
                  management: true

  it_behaves_like "nested imageable",
                  "budget_investment",
                  "new_management_budget_investment_path",
                  { budget_id: "budget_id" },
                  "imageable_fill_new_valid_budget_investment",
                  "Create Investment",
                  "Investment created successfully.",
                  management: true

  it_behaves_like "mappable",
                  "budget_investment",
                  "investment",
                  "new_management_budget_investment_path",
                  "",
                  "management_budget_investment_path",
                  { budget_id: "budget_id" },
                  management: true

  context "Load" do
    let(:investment) { create(:budget_investment, budget: budget) }

    scenario "finds investment using budget slug" do
      login_managed_user(user)
      login_as_manager(manager)
      visit management_budget_investment_path("budget_slug", investment)

      expect(page).to have_content investment.title
    end
  end

  context "Create" do
    before { heading.budget.update(phase: "accepting") }

    scenario "Creating budget investments on behalf of someone, selecting a budget" do
      login_managed_user(user)
      login_as_manager(manager)
      click_link "Create budget investment"
      within "#budget_#{budget.id}" do
        click_link "Create budget investment"
      end

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content user.username
        expect(page).to have_content user.email
        expect(page).to have_content user.document_number
      end

      fill_in_new_investment_title with: "Build a park in my neighborhood"
      fill_in_ckeditor "Description", with: "There is no parks here..."
      fill_in "budget_investment_location", with: "City center"
      fill_in "budget_investment_organization_name", with: "T.I.A."
      fill_in "budget_investment_tag_list", with: "green"

      click_button "Create Investment"

      expect(page).to have_content "Investment created successfully."

      expect(page).to have_content "Health"
      expect(page).to have_content "Build a park in my neighborhood"
      expect(page).to have_content "There is no parks here..."
      expect(page).to have_content "City center"
      expect(page).to have_content "T.I.A."
      expect(page).to have_content "green"
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(budget.created_at.to_date)
    end

    scenario "Should not allow unverified users to create budget investments" do
      login_managed_user(create(:user))

      login_as_manager(manager)
      click_link "Create budget investment"

      expect(page).to have_content "User is not verified"
    end

    scenario "Shows suggestions to unverified managers" do
      login_managed_user(user)

      expect(manager.user.level_two_or_three_verified?).to be false

      create(:budget_investment, budget: budget, title: "More parks")
      create(:budget_investment, budget: budget, title: "No more parks")
      create(:budget_investment, budget: budget, title: "Plant trees")

      login_as_manager(manager)
      click_link "Create budget investment"
      within "#budget_#{budget.id}" do
        click_link "Create budget investment"
      end

      fill_in "Title", with: "Park"
      fill_in_ckeditor "Description", with: "Wish I had one"

      within(".js-suggest") do
        expect(page).to have_content "More parks"
        expect(page).to have_content "No more parks"
        expect(page).not_to have_content "Plant trees"
      end
    end

    scenario "when user has not been selected we can't create a budget investment" do
      Setting["feature.user.skip_verification"] = "true"
      login_as_manager(manager)

      click_link "Create budget investment"

      expect(page).to have_content "To perform this action you must select a user"
      expect(page).to have_current_path management_document_verifications_path
    end
  end

  context "Searching" do
    scenario "by title" do
      budget_investment1 = create(:budget_investment, budget: budget, title: "Show me what you got")
      budget_investment2 = create(:budget_investment, budget: budget, title: "Get Schwifty")

      login_managed_user(user)
      login_as_manager(manager)
      click_link "Support budget investments"
      expect(page).to have_content(budget.name)
      within "#budget_#{budget.id}" do
        click_link "Support budget investments"
      end

      fill_in "search", with: "what you got"
      click_button "Search"

      within("#budget-investments") do
        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content(budget_investment1.title)
        expect(page).not_to have_content(budget_investment2.title)

        investment1_path = management_budget_investment_path(budget, budget_investment1)
        expect(page).to have_link(budget_investment1.title, href: investment1_path)
      end
    end

    scenario "by heading" do
      budget_investment1 = create(:budget_investment, budget: budget, title: "Hey ho",
                                                      heading: create(:budget_heading, name: "District 9"))
      budget_investment2 = create(:budget_investment, budget: budget, title: "Let's go",
                                                      heading: create(:budget_heading, name: "Area 52"))

      login_managed_user(user)
      login_as_manager(manager)
      click_link "Support budget investments"
      expect(page).to have_content(budget.name)
      within "#budget_#{budget.id}" do
        click_link "Support budget investments"
      end

      fill_in "search", with: "Area 52"
      click_button "Search"

      within("#budget-investments") do
        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).not_to have_content(budget_investment1.title)
        expect(page).to have_content(budget_investment2.title)

        investment2_path = management_budget_investment_path(budget, budget_investment2)
        expect(page).to have_link(budget_investment2.title, href: investment2_path)
      end
    end
  end

  scenario "Listing" do
    budget_investment1 = create(:budget_investment, budget: budget, title: "Show me what you got")
    budget_investment2 = create(:budget_investment, budget: budget, title: "Get Schwifty")

    login_managed_user(user)
    login_as_manager(manager)
    click_link "Support budget investments"
    expect(page).to have_content(budget.name)
    within "#budget_#{budget.id}" do
      click_link "Support budget investments"
    end

    within(".account-info") do
      expect(page).to have_content "Identified as"
      expect(page).to have_content user.username
      expect(page).to have_content user.email
      expect(page).to have_content user.document_number
    end

    within("#budget-investments") do
      expect(page).to have_css(".budget-investment", count: 2)

      investment1_path = management_budget_investment_path(budget, budget_investment1)
      expect(page).to have_link(budget_investment1.title, href: investment1_path)

      investment2_path = management_budget_investment_path(budget, budget_investment2)
      expect(page).to have_link(budget_investment2.title, href: investment2_path)
    end
  end

  scenario "Listing - managers can see budgets in accepting phase" do
    accepting_budget = create(:budget, :accepting)
    reviewing_budget = create(:budget, :reviewing)
    selecting_budget = create(:budget, :selecting)
    valuating_budget = create(:budget, :valuating)
    balloting_budget = create(:budget, :balloting)
    reviewing_ballots_budget = create(:budget, :reviewing_ballots)
    finished = create(:budget, :finished)

    login_managed_user(user)
    login_as_manager(manager)
    click_link "Create budget investment"

    expect(page).to have_content(accepting_budget.name)

    expect(page).not_to have_content(reviewing_budget.name)
    expect(page).not_to have_content(selecting_budget.name)
    expect(page).not_to have_content(valuating_budget.name)
    expect(page).not_to have_content(balloting_budget.name)
    expect(page).not_to have_content(reviewing_ballots_budget.name)
    expect(page).not_to have_content(finished.name)
  end

  scenario "Listing - admins can see budgets in accepting, reviewing and selecting phases" do
    accepting_budget = create(:budget, :accepting)
    reviewing_budget = create(:budget, :reviewing)
    selecting_budget = create(:budget, :selecting)
    valuating_budget = create(:budget, :valuating)
    balloting_budget = create(:budget, :balloting)
    reviewing_ballots_budget = create(:budget, :reviewing_ballots)
    finished = create(:budget, :finished)

    login_managed_user(user)
    login_as(create(:administrator).user)

    visit management_sign_in_path

    click_link "Create budget investment"

    expect(page).to have_content(accepting_budget.name)
    expect(page).to have_content(reviewing_budget.name)
    expect(page).to have_content(selecting_budget.name)

    expect(page).not_to have_content(valuating_budget.name)
    expect(page).not_to have_content(balloting_budget.name)
    expect(page).not_to have_content(reviewing_ballots_budget.name)
    expect(page).not_to have_content(finished.name)
  end

  context "Supporting" do
    scenario "Supporting budget investments on behalf of someone in index view" do
      budget_investment = create(:budget_investment, heading: heading)

      login_managed_user(user)
      login_as_manager(manager)
      click_link "Support budget investments"
      expect(page).to have_content(budget.name)
      within "#budget_#{budget.id}" do
        click_link "Support budget investments"
      end
      expect(page).to have_content(budget_investment.title)

      within("#budget-investments") do
        click_button "Support"

        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this investment project. Share it!"
      end
    end

    scenario "Supporting budget investments on behalf of someone in show view" do
      budget_investment = create(:budget_investment, budget: budget)
      manager.user.update!(level_two_verified_at: Time.current)

      login_managed_user(user)
      login_as_manager(manager)
      click_link "Support budget investments"
      expect(page).to have_content(budget.name)
      within "#budget_#{budget.id}" do
        click_link "Support budget investments"
      end

      within("#budget-investments") do
        click_link budget_investment.title
      end

      expect(page).to have_css "h1", exact_text: budget_investment.title

      click_button "Support"

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this investment project. Share it!"

      refresh

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this investment project. Share it!"
    end

    scenario "Support investments on behalf of someone else when there are more headings" do
      create(:budget_investment, heading: heading, title: "Default heading investment")
      create(:budget_investment, heading: create(:budget_heading, group: group))

      login_managed_user(user)
      login_as_manager(manager)

      visit management_budget_investments_path(budget)
      click_link "Default heading investment"

      expect(page).to have_css "h1", exact_text: "Default heading investment"

      accept_confirm { click_button "Support" }

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this investment project. Share it!"
      expect(page).to have_content "Investment supported successfully"
      expect(page).to have_content "CONSUL\nMANAGEMENT"
    end

    scenario "Remove support on behalf of someone else in index view" do
      Setting["feature.remove_investments_supports"] = true
      create(:budget_investment, heading: heading)

      login_managed_user(user)
      login_as_manager(manager)

      visit management_budget_investments_path(budget)
      click_button "Support"

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this investment project. Share it!"
      expect(page).not_to have_button "Support"

      click_button "Remove your support"

      expect(page).to have_content "No supports"
      expect(page).to have_button "Support"
      expect(page).not_to have_button "Remove your support"
    end

    scenario "Remove support on behalf of someone else in show view" do
      Setting["feature.remove_investments_supports"] = true
      create(:budget_investment, heading: heading, title: "Don't support me!")

      login_managed_user(user)
      login_as_manager(manager)

      visit management_budget_investments_path(budget)
      click_link "Don't support me!"

      expect(page).to have_css "h1", exact_text: "Don't support me!"

      click_button "Support"

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this investment project. Share it!"
      expect(page).not_to have_button "Support"

      click_button "Remove your support"

      expect(page).to have_content "No supports"
      expect(page).to have_button "Support"
      expect(page).not_to have_button "Remove your support"

      refresh

      expect(page).to have_content "No supports"
      expect(page).to have_button "Support"
      expect(page).not_to have_button "Remove your support"
    end

    scenario "Should not allow unverified users to vote proposals" do
      login_managed_user(create(:user))
      create(:budget_investment, budget: budget)

      login_as_manager(manager)
      click_link "Support budget investments"

      expect(page).to have_content "User is not verified"
    end

    scenario "when user has not been selected we can't support budget investments" do
      Setting["feature.user.skip_verification"] = "true"
      login_as_manager(manager)

      click_link "Support budget investments"

      expect(page).to have_content "To perform this action you must select a user"
      expect(page).to have_current_path management_document_verifications_path
    end
  end

  context "Printing" do
    scenario "Printing budget investments" do
      16.times { create(:budget_investment, heading: heading) }

      login_as_manager(manager)
      click_link "Print budget investments"

      expect(page).to have_content(budget.name)
      within "#budget_#{budget.id}" do
        click_link "Print budget investments"
      end

      expect(page).to have_css(".budget-investment", count: 15)
      expect(page).to have_link("Print", href: "javascript:window.print();")
    end

    scenario "Printing voted budget investments in balloting phase" do
      budget.update!(phase: "balloting")

      voted_investment = create(:budget_investment, :selected, heading: heading, balloters: [create(:user)])

      login_as_manager(manager)
      click_link "Print budget investments"

      within "#budget_#{budget.id}" do
        click_link "Print budget investments"
      end

      expect(page).to have_content voted_investment.title
      expect(page).to have_link("Print", href: "javascript:window.print();")
    end

    scenario "Filtering budget investments by heading to be printed" do
      district_9 = create(:budget_heading, group: group, name: "District Nine")
      another_heading = create(:budget_heading, group: group)
      low_investment = create(:budget_investment,
                              budget: budget,
                              title: "Nuke district 9",
                              heading: district_9,
                              cached_votes_up: 1)
      mid_investment = create(:budget_investment,
                              budget: budget,
                              title: "Change district 9",
                              heading: district_9,
                              cached_votes_up: 10)
      top_investment = create(:budget_investment,
                              budget: budget,
                              title: "Destroy district 9",
                              heading: district_9,
                              cached_votes_up: 100)
      unvoted_investment = create(:budget_investment,
                                  budget: budget,
                                  heading: another_heading,
                                  title: "Add new districts to the city")

      login_as_manager(manager)
      click_link "Print budget investments"

      expect(page).to have_content(budget.name)
      within "#budget_#{budget.id}" do
        click_link "Print budget investments"
      end

      within "#budget-investments" do
        expect(page).to have_content(unvoted_investment.title)
        expect(page).to have_content(mid_investment.title)
        expect(page).to have_content(top_investment.title)
        expect(page).to have_content(low_investment.title)
      end

      select "District Nine", from: "heading_id"
      click_button("Search")

      within "#budget-investments" do
        expect(page).not_to have_content(unvoted_investment.title)
        expect(top_investment.title).to appear_before(mid_investment.title)
        expect(mid_investment.title).to appear_before(low_investment.title)
      end
    end
  end
end
