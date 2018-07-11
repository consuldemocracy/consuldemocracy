require 'rails_helper'

feature 'Executions' do

  let(:budget)  { create(:budget, phase: 'finished') }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  let!(:investment1) { create(:budget_investment, :selected,     heading: heading, price: 200, ballot_lines_count: 900) }
  let!(:investment2) { create(:budget_investment, :selected,     heading: heading, price: 300, ballot_lines_count: 800) }
  let!(:investment3) { create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700) }
  let!(:investment4) { create(:budget_investment, :selected,     heading: heading, price: 600, ballot_lines_count: 600) }

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

  scenario 'render a message for headings without winner investments' do
    empty_group   = create(:budget_group, budget: budget)
    empty_heading = create(:budget_heading, group: empty_group, price: 1000)

    visit budget_path(budget)
    click_link 'See results'

    expect(page).to have_content(heading.name)
    expect(page).to have_content(empty_heading.name)

    click_link 'Milestones'
    click_link "#{empty_heading.name}"

    expect(page).to have_content('No winner investments for this heading')
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
                                                        publication_date: Date.yesterday)

      milestone2 = create(:budget_investment_milestone, investment: investment1,
                                                        publication_date: Date.tomorrow)

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

    scenario 'by milestone status', :js do
      create(:budget_investment_milestone, investment: investment1, status: status1)
      create(:budget_investment_milestone, investment: investment2, status: status2)
      create(:budget_investment_status, name: I18n.t('seeds.budgets.statuses.executing_project'))

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment1.title)
      expect(page).to have_content(investment2.title)

      select 'Studying the project', from: 'status'

      expect(page).to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)

      select 'Bidding', from: 'status'

      expect(page).to have_content(investment2.title)
      expect(page).not_to have_content(investment1.title)

      select 'Executing the project', from: 'status'

      expect(page).not_to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    xscenario 'are based on latest milestone status', :js do
      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: Date.yesterday,
                                           status: status1)

      create(:budget_investment_milestone, investment: investment1,
                                           publication_date: Date.tomorrow,
                                           status: status2)

      visit budget_path(budget)

      click_link 'See results'
      click_link 'Milestones'

      expect(page).to have_content(investment1.title)

      select 'Studying the project', from: 'status'

      expect(page).not_to have_content(investment1.title)

      select 'Bidding', from: 'status'

      expect(page).to have_content(investment1.title)
    end
  end

end
