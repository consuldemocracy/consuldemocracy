require 'rails_helper'

feature 'Admin budgets' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context 'Feature flag' do

    background do
      Setting['feature.budgets'] = nil
    end

    after do
      Setting['feature.budgets'] = true
    end

    scenario 'Disabled with a feature flag' do
      expect{ visit admin_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context 'Index' do

    scenario 'Displaying no open budgets text' do
      visit admin_budgets_path

      expect(page).to have_content("There are no open budgets.")
    end

    scenario 'Displaying budgets' do
      budget = create(:budget)
      visit admin_budgets_path

      expect(page).to have_content(budget.name)
      expect(page).to have_content(translated_phase_name(phase_kind: budget.phase))
    end

    scenario 'Filters by phase' do
      drafting_budget  = create(:budget, :drafting)
      accepting_budget = create(:budget, :accepting)
      selecting_budget = create(:budget, :selecting)
      balloting_budget = create(:budget, :balloting)
      finished_budget  = create(:budget, :finished)

      visit admin_budgets_path
      expect(page).to have_content(drafting_budget.name)
      expect(page).to have_content(accepting_budget.name)
      expect(page).to have_content(selecting_budget.name)
      expect(page).to have_content(balloting_budget.name)
      expect(page).not_to have_content(finished_budget.name)

      click_link 'Finished'
      expect(page).not_to have_content(drafting_budget.name)
      expect(page).not_to have_content(accepting_budget.name)
      expect(page).not_to have_content(selecting_budget.name)
      expect(page).not_to have_content(balloting_budget.name)
      expect(page).to have_content(finished_budget.name)

      click_link 'Open'
      expect(page).to have_content(drafting_budget.name)
      expect(page).to have_content(accepting_budget.name)
      expect(page).to have_content(selecting_budget.name)
      expect(page).to have_content(balloting_budget.name)
      expect(page).not_to have_content(finished_budget.name)
    end

    scenario 'Open filter is properly highlighted' do
      filters_links = {'current' => 'Open', 'finished' => 'Finished'}

      visit admin_budgets_path

      expect(page).not_to have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each_pair do |current_filter, link|
        visit admin_budgets_path(filter: current_filter)

        expect(page).not_to have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

  end

  context 'New' do

    scenario 'Create budget' do
      visit admin_budgets_path
      click_link 'Create new budget'

      fill_in 'budget_name', with: 'M30 - Summer campaign'
      select 'Accepting projects', from: 'budget[phase]'

      click_button 'Create Budget'

      expect(page).to have_content 'New participatory budget created successfully!'
      expect(page).to have_content 'M30 - Summer campaign'
    end

    scenario 'Name is mandatory' do
      visit new_admin_budget_path
      click_button 'Create Budget'

      expect(page).not_to have_content 'New participatory budget created successfully!'
      expect(page).to have_css("label.error", text: "Name")
    end

  end

  context 'Destroy' do

    let!(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, group: create(:budget_group, budget: budget)) }

    scenario 'Destroy a budget without investments' do
      visit admin_budgets_path
      click_link 'Edit budget'
      click_link 'Delete budget'

      expect(page).to have_content('Budget deleted successfully')
      expect(page).to have_content('There are no open budgets.')
    end

    scenario 'Try to destroy a budget with investments' do
      create(:budget_investment, heading: heading)

      visit admin_budgets_path
      click_link 'Edit budget'
      click_link 'Delete budget'

      expect(page).to have_content('You cannot destroy a Budget that has associated investments')
      expect(page).to have_content('There is 1 budget')
    end
  end

  context 'Edit' do
    let!(:budget) { create(:budget) }

    scenario 'Show phases table' do
      visit admin_budgets_path
      click_link 'Edit budget'

      within '#budget-phases-table' do

        Budget::Phase::PHASE_KINDS.each do |phase_kind|
          phase_index = Budget::Phase::PHASE_KINDS.index(phase_kind)
          break if phase_kind == Budget::Phase::PHASE_KINDS.last
          next_phase_kind = Budget::Phase::PHASE_KINDS[phase_index + 1]
          next_phase_name = translated_phase_name(phase_kind: next_phase_kind)
          expect(translated_phase_name(phase_kind: phase_kind)).to appear_before(next_phase_name)
        end

        budget.phases.each do |phase|
          edit_phase_link = edit_admin_budget_budget_phase_path(budget, phase)

          within "#budget_phase_#{phase.id}" do
            expect(page).to have_content(translated_phase_name(phase_kind: phase.kind))
            expect(page).to have_content("#{phase.starts_at.to_date} - #{phase.ends_at.to_date}")
            expect(page).to have_css('.budget-phase-enabled.enabled')
            expect(page).to have_link('Edit phase', href: edit_phase_link)
            expect(page).to have_content('Active') if budget.current_phase == phase
          end
        end
      end
    end
  end

  context 'Update' do

    background do
      create(:budget)
    end

    scenario 'Update budget' do
      visit admin_budgets_path
      click_link 'Edit budget'

      fill_in 'budget_name', with: 'More trees on the streets'
      click_button 'Update Budget'

      expect(page).to have_content('More trees on the streets')
      expect(page).to have_current_path(admin_budgets_path)
    end

  end

  context "Calculate Budget's Winner Investments" do

    scenario 'For a Budget in reviewing balloting', :js do
      budget = create(:budget, phase: 'reviewing_ballots')
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group, price: 4)
      unselected = create(:budget_investment, :unselected, heading: heading, price: 1,
                                                           ballot_lines_count: 3)
      winner = create(:budget_investment, :selected, heading: heading, price: 3,
                                                   ballot_lines_count: 2)
      selected = create(:budget_investment, :selected, heading: heading, price: 2, ballot_lines_count: 1)

      visit edit_admin_budget_path(budget)
      expect(page).not_to have_content 'See results'
      click_link 'Calculate Winner Investments'
      expect(page).to have_content 'Winners being calculated, it may take a minute.'
      expect(page).to have_content winner.title
      expect(page).not_to have_content unselected.title
      expect(page).not_to have_content selected.title


      visit edit_admin_budget_path(budget)
      expect(page).to have_content 'See results'
    end

    scenario 'For a finished Budget' do
      budget = create(:budget, phase: 'finished')
      allow_any_instance_of(Budget).to receive(:has_winning_investments?).and_return true

      visit edit_admin_budget_path(budget)

      expect(page).not_to have_content 'Calculate Winner Investments'
      expect(page).to have_content 'See results'
    end

  end
end

def translated_phase_name(phase_kind: kind)
  I18n.t("budgets.phase.#{phase_kind}")
end
