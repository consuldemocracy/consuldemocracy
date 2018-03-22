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

  scenario "Change name", :js do
    visit admin_budget_path(group.budget)
    within("#budget_group_#{group.id}") do
      click_link 'Edit group'
      within("#group-form-#{group.id}") do
        fill_in 'budget_group_name', with: 'Google'
        click_button 'Save group'
      end
    end

    expect(page).to have_content('Google')
  end

  scenario "Can change name when the budget isn't drafting, but the slug remains", :js do
    old_slug = group.slug
    budget.update(phase: 'reviewing')
    visit admin_budget_path(group.budget)

    within("#budget_group_#{group.id}") do
      click_link 'Edit group'
      within("#group-form-#{group.id}") do
        fill_in 'budget_group_name', with: 'Google'
        click_button 'Save group'
      end
    end

    group.reload

    expect(page).to have_content('Google')
    expect(group.slug).to eq old_slug
  end

  scenario "Can't repeat names", :js  do
    group.budget.groups << create(:budget_group, name: 'group_name')
    visit admin_budget_path(group.budget)

    within("#budget_group_#{group.id}") do
      click_link 'Edit group'
      within("#group-form-#{group.id}") do
        fill_in 'budget_group_name', with: 'group_name'
        click_button 'Save group'
      end
    end

    expect(page).to have_content('has already been taken')
  end

end
