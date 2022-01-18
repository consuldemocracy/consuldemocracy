require "rails_helper"

describe "Executions" do
  let(:budget)  { create(:budget, :finished) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group) }

  let!(:investment1) { create(:budget_investment, :winner,       heading: heading) }
  let!(:investment2) { create(:budget_investment, :winner,       heading: heading) }
  let!(:investment4) { create(:budget_investment, :winner,       heading: heading) }
  let!(:investment3) { create(:budget_investment, :incompatible, heading: heading) }

  scenario "finds budget by id or slug" do
    budget.update!(slug: "budget_slug")

    visit budget_executions_path("budget_slug")
    within(".budgets-stats") { expect(page).to have_content budget.name }

    visit budget_executions_path(budget)
    within(".budgets-stats") { expect(page).to have_content budget.name }

    visit budget_executions_path("budget_slug")
    within(".budgets-stats") { expect(page).to have_content budget.name }

    visit budget_executions_path(budget)
    within(".budgets-stats") { expect(page).to have_content budget.name }
  end

  scenario "only displays investments with milestones" do
    create(:milestone, milestoneable: investment1)

    visit budget_path(budget)
    click_link "See results"

    expect(page).to have_link("Milestones")

    click_link "Milestones"

    expect(page).to have_content(investment1.title)
    expect(page).not_to have_content(investment2.title)
    expect(page).not_to have_content(investment3.title)
    expect(page).not_to have_content(investment4.title)
  end

  scenario "Do not display headings with no winning investments for selected status" do
    create(:milestone, milestoneable: investment1)

    empty_group   = create(:budget_group, budget: budget)
    empty_heading = create(:budget_heading, group: empty_group, price: 1000)

    visit budget_path(budget)
    click_link "See results"

    expect(page).to have_content(heading.name)
    expect(page).to have_content(empty_heading.name)

    click_link "Milestones"

    expect(page).to have_content(heading.name)
    expect(page).not_to have_content(empty_heading.name)
  end

  scenario "Show message when there are no winning investments with the selected status" do
    create(:milestone_status, name: I18n.t("seeds.budgets.statuses.executed"))

    visit budget_path(budget)

    click_link "See results"
    click_link "Milestones"

    expect(page).to have_content("No winner investments in this state")

    select "Executed (0)", from: "Project's current state"
    click_button "Filter"

    expect(page).to have_content("No winner investments in this state")
  end

  context "Images" do
    scenario "renders milestone image if available" do
      milestone1 = create(:milestone, :with_image, milestoneable: investment1)

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content(investment1.title)
      expect(page).to have_css("img[alt='#{milestone1.image.title}']")
    end

    scenario "renders investment image if no milestone image is available" do
      create(:milestone, milestoneable: investment2)
      create(:image, imageable: investment2)

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content(investment2.title)
      expect(page).to have_css("img[alt='#{investment2.image.title}']")
    end

    scenario "renders default image if no milestone nor investment images are available" do
      create(:milestone, milestoneable: investment4)

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content(investment4.title)
      expect(page).to have_css("img[alt='#{investment4.title}']")
    end

    scenario "renders last milestone's image if investment has multiple milestones with images associated" do
      create(:milestone, milestoneable: investment1)
      create(:milestone, :with_image, image_title: "First image", milestoneable: investment1)
      create(:milestone, :with_image, image_title: "Second image", milestoneable: investment1)
      create(:milestone, milestoneable: investment1)

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content(investment1.title)
      expect(page).to have_css("img[alt='Second image']")
    end
  end

  context "Filters" do
    let!(:status1) { create(:milestone_status, name: "Studying the project") }
    let!(:status2) { create(:milestone_status, name: "Bidding") }

    scenario "Filters select with counter are shown" do
      create(:milestone, milestoneable: investment1,
                         publication_date: Date.yesterday,
                         status: status1)

      create(:milestone, milestoneable: investment2,
                         publication_date: Date.yesterday,
                         status: status2)

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content("All (2)")
      expect(page).to have_content("#{status1.name} (1)")
      expect(page).to have_content("#{status2.name} (1)")
    end

    scenario "by milestone status" do
      create(:milestone, milestoneable: investment1, status: status1)
      create(:milestone, milestoneable: investment2, status: status2)
      create(:milestone_status, name: I18n.t("seeds.budgets.statuses.executing_project"))

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content(investment1.title)
      expect(page).to have_content(investment2.title)

      select "Studying the project (1)", from: "Project's current state"
      click_button "Filter"

      expect(page).to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)

      select "Bidding (1)", from: "Project's current state"
      click_button "Filter"

      expect(page).to have_content(investment2.title)
      expect(page).not_to have_content(investment1.title)

      select "Executing the project (0)", from: "Project's current state"
      click_button "Filter"

      expect(page).not_to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    scenario "are based on latest milestone status" do
      create(:milestone, milestoneable: investment1,
                         publication_date: 1.month.ago,
                         status: status1)

      create(:milestone, milestoneable: investment1,
                         publication_date: Date.yesterday,
                         status: status2)

      visit budget_path(budget)
      click_link "See results"
      click_link "Milestones"

      select "Studying the project (0)", from: "Project's current state"
      click_button "Filter"

      expect(page).not_to have_content(investment1.title)

      select "Bidding (1)", from: "Project's current state"
      click_button "Filter"

      expect(page).to have_content(investment1.title)
    end

    scenario "milestones with future dates are not shown" do
      create(:milestone, milestoneable: investment1,
                         publication_date: Date.yesterday,
                         status: status1)

      create(:milestone, milestoneable: investment1,
                         publication_date: Date.tomorrow,
                         status: status2)

      visit budget_path(budget)
      click_link "See results"
      click_link "Milestones"

      select "Studying the project (1)", from: "Project's current state"
      click_button "Filter"

      expect(page).to have_content(investment1.title)

      select "Bidding (0)", from: "Project's current state"
      click_button "Filter"

      expect(page).not_to have_content(investment1.title)
    end

    scenario "by milestone tag, only display tags for winner investments" do
      create(:milestone, milestoneable: investment1, status: status1)
      create(:milestone, milestoneable: investment2, status: status2)
      create(:milestone, milestoneable: investment3, status: status2)
      investment1.milestone_tag_list.add("tag1", "tag2")
      investment1.save!
      investment2.milestone_tag_list.add("tag2")
      investment2.save!
      investment3.milestone_tag_list.add("tag2")
      investment3.save!

      visit budget_path(budget)

      click_link "See results"
      click_link "Milestones"

      expect(page).to have_content(investment1.title)
      expect(page).to have_content(investment2.title)

      select "tag2 (2)", from: "Milestone tag"
      select "Studying the project (1)", from: "Project's current state"
      click_button "Filter"

      expect(page).to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)

      select "Bidding (1)", from: "Project's current state"
      click_button "Filter"

      expect(page).not_to have_content(investment1.title)
      expect(page).to have_content(investment2.title)

      select "tag1 (1)", from: "Milestone tag"
      click_button "Filter"

      expect(page).not_to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)

      select "All (2)", from: "Milestone tag"
      click_button "Filter"

      expect(page).not_to have_content(investment1.title)
      expect(page).to have_content(investment2.title)
    end
  end

  context "Heading Order" do
    scenario "Non-city headings are displayed in alphabetical order" do
      heading.destroy!
      z_heading = create(:budget_heading, :with_investment_with_milestone, group: group, name: "Zzz")
      a_heading = create(:budget_heading, :with_investment_with_milestone, group: group, name: "Aaa")
      m_heading = create(:budget_heading, :with_investment_with_milestone, group: group, name: "Mmm")

      visit budget_executions_path(budget)

      expect(page).to have_css(".budget-execution", count: 3)
      expect(a_heading.name).to appear_before(m_heading.name)
      expect(m_heading.name).to appear_before(z_heading.name)
    end
  end

  context "No milestones" do
    scenario "Milestone not yet published" do
      status = create(:milestone_status)
      create(:milestone, milestoneable: investment1, status: status, publication_date: Date.tomorrow)

      visit budget_executions_path(budget, status: status.id)

      expect(page).to have_content("No winner investments in this state")
    end
  end
end
