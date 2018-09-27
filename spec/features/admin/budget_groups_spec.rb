require 'rails_helper'

feature 'Admin can change the groups name' do

  let(:budget) { create(:budget, phase: 'drafting') }
  let(:group) { create(:budget_group, budget: budget) }

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Show button" do
    visit admin_budget_path(group.budget)

    within("#budget_group_#{group.id}") do
      expect(page).to have_content('Edit group')
    end
  end

  scenario "Change name" do
    group.update(name: 'Google')
    expect(group.name).to eq('Google')
  end

  scenario "Can change name when the budget isn't drafting, but the slug remains" do
    old_slug = group.slug
    budget.update(phase: 'reviewing')
    group.update(name: 'Google')

    expect(group.name).to eq('Google')
    expect(group.slug).to eq old_slug
  end

  scenario "Can't repeat names" do
    budget.groups << create(:budget_group, name: 'group_name')
    group.name = 'group_name'

    expect(group).not_to be_valid
    expect(group.errors.size).to eq(1)
  end

  context "Maximum votable headings" do

    background do
      3.times { create(:budget_heading, group: group) }
    end

    scenario "Defaults to 1 heading per group", :js do
      visit admin_budget_path(group.budget)

      expect(page).to have_content('Maximum number of headings in which a user can vote 1 of 3')

      within("#budget_group_#{group.id}") do
        click_link 'Edit group'

        expect(page).to have_select('budget_group_max_votable_headings', selected: '1')
      end
    end

    scenario "Update", :js do
      visit admin_budget_path(group.budget)

      within("#budget_group_#{group.id}") do
        click_link 'Edit group'

        select '2', from: 'budget_group_max_votable_headings'
        click_button 'Save group'
      end

      expect(page).to have_content('Maximum number of headings in which a user can vote 2 of 3')

      within("#budget_group_#{group.id}") do
        click_link 'Edit group'

        expect(page).to have_select('budget_group_max_votable_headings', selected: '2')
      end
    end

    scenario "Do not display maximum votable headings' select in new form", :js do
      visit admin_budget_path(group.budget)

      click_link 'Add new group'

      expect(page).to have_field('budget_group_name')
      expect(page).not_to have_field('budget_group_max_votable_headings')
    end

  end
end
