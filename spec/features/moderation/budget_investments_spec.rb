require 'rails_helper'

feature 'Moderate budget investments' do

  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, name: 'Culture', budget: budget) }
  let(:heading) { create(:budget_heading, name: 'More libraries', price: 666666, group: group) }

  background do
    @mod        = create(:moderator)
    @investment = create(:budget_investment, heading: heading, author: create(:user))
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.budgets'] = nil
    login_as(@mod.user)

    expect{ visit moderation_budget_investments_path }.to raise_exception(FeatureFlags::FeatureDisabled)

    Setting['feature.budgets'] = true
  end

  scenario 'Hiding an investment', :js do
    login_as(@mod.user)
    visit budget_investment_path(budget, @investment)

    accept_confirm { click_link 'Hide' }

    expect(page).to have_css('.faded', count: 2)

    visit budget_investments_path(budget.id, heading_id: heading.id)

    expect(page).not_to have_content(@investment.title)
  end

  scenario "Hiding an investment's author", :js do
    login_as(@mod.user)
    visit budget_investment_path(budget, @investment)

    accept_confirm { click_link 'Hide author' }

    expect(page).to have_current_path(debates_path)

    visit budget_investments_path(budget.id, heading_id: heading.id)

    expect(page).not_to have_content(@investment.title)
  end

  scenario 'Can not hide own investment' do
    @investment.update(author: @mod.user)
    login_as(@mod.user)

    visit budget_investment_path(budget, @investment)

    within "#budget_investment_#{@investment.id}" do
      expect(page).not_to have_link('Hide')
      expect(page).not_to have_link('Hide author')
    end
  end

  feature '/moderation/ screen' do

    background do
      login_as(@mod.user)
    end

    feature 'moderate in bulk' do
      feature 'When an investment has been selected for moderation' do

        background do
          visit moderation_budget_investments_path

          within('.menu.simple') do
            click_link 'All'
          end

          within("#investment_#{@investment.id}") do
            check "budget_investment_#{@investment.id}_check"
          end

          expect(page).not_to have_css("investment#{@investment.id}")
        end

        scenario 'Hide the investment' do
          click_button 'Hide budget investments'
          expect(page).not_to have_css("investment_#{@investment.id}")

          @investment.reload

          expect(@investment.author).not_to be_hidden
        end

        scenario 'Block the author' do
          click_button 'Block authors'
          expect(page).not_to have_css("investment_#{@investment.id}")

          @investment.reload

          expect(@investment.author).to be_hidden
        end

        scenario 'Ignore the investment' do
          click_button 'Mark as viewed'
          expect(page).not_to have_css("investment_#{@investment.id}")

          @investment.reload

          expect(@investment).to be_ignored_flag
          expect(@investment).not_to be_hidden
          expect(@investment.author).not_to be_hidden
        end
      end

      scenario 'select all/none', :js do
        create_list(:budget_investment, 2, heading: heading, author: create(:user))

        visit moderation_budget_investments_path

        within('.js-check') { click_on 'All' }

        expect(all('input[type=checkbox]')).to all(be_checked)

        within('.js-check') { click_on 'None' }

        all('input[type=checkbox]').each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end

      scenario 'remembering page, filter and order' do
        create_list(:budget_investment, 52, heading: heading, author: create(:user))

        visit moderation_budget_investments_path(filter: 'all', page: '2', order: 'created_at')

        click_button 'Mark as viewed'

        expect(page).to have_selector('.js-order-selector[data-order="created_at"]')

        expect(current_url).to include('filter=all')
        expect(current_url).to include('page=2')
        expect(current_url).to include('order=created_at')
      end
    end

    scenario 'Current filter is properly highlighted' do
      visit moderation_budget_investments_path

      expect(page).not_to have_link('Pending')
      expect(page).to have_link('All')
      expect(page).to have_link('Marked as viewed')

      visit moderation_budget_investments_path(filter: 'all')

      within('.menu.simple') do
        expect(page).not_to have_link('All')
        expect(page).to have_link('Pending')
        expect(page).to have_link('Marked as viewed')
      end

      visit moderation_budget_investments_path(filter: 'pending_flag_review')

      within('.menu.simple') do
        expect(page).to have_link('All')
        expect(page).not_to have_link('Pending')
        expect(page).to have_link('Marked as viewed')
      end

      visit moderation_budget_investments_path(filter: 'with_ignored_flag')

      within('.menu.simple') do
        expect(page).to have_link('All')
        expect(page).to have_link('Pending')
        expect(page).not_to have_link('Marked as viewed')
      end
    end

    scenario 'Filtering investments' do
      create(:budget_investment, heading: heading, title: 'Books investment')
      create(:budget_investment, :flagged, heading: heading, title: 'Non-selected investment')
      create(:budget_investment, :hidden, heading: heading, title: 'Hidden investment')
      create(:budget_investment, :flagged, :with_ignored_flag, heading: heading, title: 'Ignored investment')

      visit moderation_budget_investments_path(filter: 'all')

      expect(page).to have_content('Books investment')
      expect(page).to have_content('Non-selected investment')
      expect(page).not_to have_content('Hidden investment')
      expect(page).to have_content('Ignored investment')

      visit moderation_budget_investments_path(filter: 'pending_flag_review')

      expect(page).not_to have_content('Books investment')
      expect(page).to have_content('Non-selected investment')
      expect(page).not_to have_content('Hidden investment')
      expect(page).not_to have_content('Ignored investment')

      visit moderation_budget_investments_path(filter: 'with_ignored_flag')

      expect(page).not_to have_content('Books investment')
      expect(page).not_to have_content('Non-selected investment')
      expect(page).not_to have_content('Hidden investment')
      expect(page).to have_content('Ignored investment')
    end

    scenario 'sorting investments' do
      flagged_investment = create(:budget_investment,
        heading: heading,
        title: 'Flagged investment',
        created_at: Time.current - 1.day,
        flags_count: 5
      )

      flagged_new_investment = create(:budget_investment,
        heading: heading,
        title: 'Flagged new investment',
        created_at: Time.current - 12.hours,
        flags_count: 3
      )

      latest_investment = create(:budget_investment,
        heading: heading,
        title: 'Latest investment',
        created_at: Time.current
      )

      visit moderation_budget_investments_path(order: 'created_at')

      expect(flagged_new_investment.title).to appear_before(flagged_investment.title)

      visit moderation_budget_investments_path(order: 'flags')

      expect(flagged_investment.title).to appear_before(flagged_new_investment.title)

      visit moderation_budget_investments_path(filter: 'all', order: 'created_at')

      expect(latest_investment.title).to appear_before(flagged_new_investment.title)
      expect(flagged_new_investment.title).to appear_before(flagged_investment.title)

      visit moderation_budget_investments_path(filter: 'all', order: 'flags')

      expect(flagged_investment.title).to appear_before(flagged_new_investment.title)
      expect(flagged_new_investment.title).to appear_before(latest_investment.title)
    end
  end

end
