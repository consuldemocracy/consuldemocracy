require 'rails_helper'

feature 'Executions' do

  let(:budget)  { create(:budget, phase: 'finished') }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group) }

  let!(:investment1) { create(:budget_investment, :winner,       heading: heading) }
  let!(:investment2) { create(:budget_investment, :winner,       heading: heading) }
  let!(:investment4) { create(:budget_investment, :winner,       heading: heading) }
  let!(:investment3) { create(:budget_investment, :incompatible, heading: heading) }

  scenario 'only displays investments with milestones' do
    create(:budget_investment_milestone, investment: investment1)

    visit budget_path(budget)
    click_link 'See results'

    expect(page).to have_link('Milestones')

    click_link 'Milestones'

    expect(page).to have_content(investment1.title)
    expect(page).not_to have_content(investment2.title)
    expect(page).not_to have_content(investment3.title)
    expect(page).not_to have_content(investment4.title)
  end

  scenario "Do not display headings with no winning investments for selected status" do
    create(:budget_investment_milestone, investment: investment1)

    empty_group   = create(:budget_group, budget: budget)
    empty_heading = create(:budget_heading, group: empty_group, price: 1000)

    visit budget_path(budget)
    click_link 'See results'

    expect(page).to have_content(heading.name)
    expect(page).to have_content(empty_heading.name)

    click_link 'Milestones'

    expect(page).to have_content(heading.name)
    expect(page).not_to have_content(empty_heading.name)
  end

  scenario "Show message when there are no winning investments with the selected status", :js do
    create(:budget_investment_status, name: I18n.t('seeds.budgets.statuses.executed'))

    visit budget_path(budget)

    click_link 'See results'
    click_link 'Milestones'

    expect(page).not_to have_content('No winner investments in this state')

    select 'Executed (0)', from: 'status'

    expect(page).to have_content('No winner investments in this state')
  end

  context 'Images' do
    scenario 'renders milestone image if available' do
      milestone1 = create(:budget_investment_milestone, investment: investment1)
      create(:image, imageable: milestone1)

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment1.title)
      expect(page).to have_css("img[alt='#{milestone1.image.title}']")
    end

    scenario 'renders investment image if no milestone image is available' do
      create(:budget_investment_milestone, investment: investment2)
      create(:image, imageable: investment2)

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment2.title)
      expect(page).to have_css("img[alt='#{investment2.image.title}']")
    end

    scenario 'renders default image if no milestone nor investment images are available' do
      create(:budget_investment_milestone, investment: investment4)

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment4.title)
      expect(page).to have_css("img[alt='#{investment4.title}']")
    end

    scenario "renders last milestone's image if investment has multiple milestones with images associated" do
      milestone1 = create(:budget_investment_milestone, investment: investment1,
                                                        publication_date: 2.weeks.ago)

      milestone2 = create(:budget_investment_milestone, investment: investment1,
                                                        publication_date: Date.yesterday)

      create(:image, imageable: milestone1, title: 'First milestone image')
      create(:image, imageable: milestone2, title: 'Second milestone image')

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment1.title)
      expect(page).to have_css("img[alt='#{milestone2.image.title}']")
      expect(page).not_to have_css("img[alt='#{milestone1.image.title}']")
    end
  end

  context 'Filters' do

    let!(:status1) { create(:budget_investment_status, name: I18n.t('seeds.budgets.statuses.studying_project')) }
    let!(:status2) { create(:budget_investment_status, name: I18n.t('seeds.budgets.statuses.bidding')) }

    scenario 'Filters select with counter are shown' do
      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: Date.yesterday,
                                           status: status1)

      create(:budget_investment_milestone, investment: investment2,
                                           publication_date: Date.yesterday,
                                           status: status2)

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content("All (2)")
      expect(page).to have_content("#{status1.name} (1)")
      expect(page).to have_content("#{status2.name} (1)")
    end

    scenario 'by milestone status', :js do
      create(:budget_investment_milestone, investment: investment1, status: status1)
      create(:budget_investment_milestone, investment: investment2, status: status2)
      create(:budget_investment_status, name: I18n.t('seeds.budgets.statuses.executing_project'))

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment1.title)
      expect(page).to have_content(investment2.title)

      select 'Studying the project (1)', from: 'status'

      expect(page).to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)

      select 'Bidding (1)', from: 'status'

      expect(page).to have_content(investment2.title)
      expect(page).not_to have_content(investment1.title)

      select 'Executing the project (0)', from: 'status'

      expect(page).not_to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    scenario 'are based on latest milestone status', :js do
      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: 1.month.ago,
                                           status: status1)

      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: Date.yesterday,
                                           status: status2)

      visit budget_path(budget)
      click_link 'See results'
      click_link 'Milestones'

      select 'Studying the project (0)', from: 'status'
      expect(page).not_to have_content(investment1.title)

      select 'Bidding (1)', from: 'status'
      expect(page).to have_content(investment1.title)
    end

    scenario 'milestones with future dates are not shown', :js do
      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: Date.yesterday,
                                           status: status1)

      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: Date.tomorrow,
                                           status: status2)

      visit budget_path(budget)
      click_link 'See results'
      click_link 'Milestones'

      select 'Studying the project (1)', from: 'status'
      expect(page).to have_content(investment1.title)

      select 'Bidding (0)', from: 'status'
      expect(page).not_to have_content(investment1.title)
    end
  end

  context 'Spending Proposals' do
    let!(:budget) { create(:budget, :finished, slug: '2016') }

    scenario 'can navigate from spending proposal Results page to Executions page' do
      create(:budget_investment_milestone, investment: investment1)

      visit participatory_budget_results_path

      click_on 'Milestones'

      expect(page).to have_current_path(participatory_budget_executions_path)
      expect(page).to have_css('.budget-execution', count: 1)
      within('.budget-execution') do
        expect(page).to have_content(investment1.title)
      end
    end

    scenario 'renders spending proposal navigation when accessing 2016 budget' do
      create(:budget_investment_milestone, investment: investment1)

      visit participatory_budget_executions_path

      expect(page).to have_current_path(participatory_budget_executions_path)

      click_on 'Results'

      expect(page).to have_current_path(participatory_budget_results_path)
    end
  end

  context 'Heading Order' do

    def create_heading_with_investment_with_milestone(group:, name:)
      heading    = create(:budget_heading, group: group, name: name)
      investment = create(:budget_investment, :winner, heading: heading)
      milestone  = create(:budget_investment_milestone, investment: investment)
      heading
    end

    scenario 'City heading is displayed first' do
      heading.destroy!
      other_heading1 = create_heading_with_investment_with_milestone(group: group, name: 'Other 1')
      city_heading   = create_heading_with_investment_with_milestone(group: group, name: 'Toda la ciudad')
      other_heading2 = create_heading_with_investment_with_milestone(group: group, name: 'Other 2')

      visit custom_budget_executions_path(budget)

      expect(page).to have_css('.budget-execution', count: 3)
      expect(city_heading.name).to appear_before(other_heading1.name)
      expect(city_heading.name).to appear_before(other_heading2.name)
    end

    scenario 'Non-city headings are displayed in alphabetical order' do
      heading.destroy!
      z_heading = create_heading_with_investment_with_milestone(group: group, name: 'Zzz')
      a_heading = create_heading_with_investment_with_milestone(group: group, name: 'Aaa')
      m_heading = create_heading_with_investment_with_milestone(group: group, name: 'Mmm')

      visit custom_budget_executions_path(budget)

      expect(page).to have_css('.budget-execution', count: 3)
      expect(a_heading.name).to appear_before(m_heading.name)
      expect(m_heading.name).to appear_before(z_heading.name)
    end
  end

  context 'No milestones' do

    scenario 'Milestone not yet published' do
      status = create(:budget_investment_status)
      unpublished_milestone = create(:budget_investment_milestone, investment: investment1,
                                     status: status, publication_date: Date.tomorrow)

      visit custom_budget_executions_path(budget, status: status.id)

      expect(page).to have_content('No winner investments in this state')
    end

  end
end
