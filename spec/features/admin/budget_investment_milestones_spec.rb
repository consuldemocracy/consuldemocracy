require 'rails_helper'

feature 'Admin budget investment milestones' do

  background do
    admin = create(:administrator)
    login_as(admin.user)

    @investment = create(:budget_investment)
  end

  context "Index" do
    scenario 'Displaying milestones' do
      milestone = create(:budget_investment_milestone, investment: @investment)

      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      expect(page).to have_content("Milestone")
      expect(page).to have_content(milestone.title)
      expect(page).to have_content(milestone.id)
    end

    scenario 'Displaying no_milestones text' do
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      expect(page).to have_content("Milestone")
      expect(page).to have_content("Don't have defined milestones")
    end
  end

  context "New" do
    scenario "Add milestone" do
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link 'Create new milestone'

      fill_in 'budget_investment_milestone_title', with: 'New title milestone'
      fill_in 'budget_investment_milestone_description', with: 'New description milestone'

      click_button 'Create milestone'

      expect(page).to have_content 'New title milestone'
      expect(page).to have_content 'New description milestone'
    end

    scenario "Show validation errors on milestone form" do
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link 'Create new milestone'

      fill_in 'budget_investment_milestone_description', with: 'New description milestone'

      click_button 'Create milestone'

      within "#new_budget_investment_milestone" do
        expect(page).to have_content "can't be blank"
        expect(page).to have_content 'New description milestone'
      end
    end
  end

  context "Edit" do
    scenario "Change title and description" do
      milestone = create(:budget_investment_milestone, investment: @investment)

      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link milestone.title

      fill_in 'budget_investment_milestone_title', with: 'Changed title'
      fill_in 'budget_investment_milestone_description', with: 'Changed description'

      click_button 'Update milestone'

      expect(page).to have_content 'Changed title'
      expect(page).to have_content 'Changed description'
    end
  end

  context "Delete" do
    scenario "Remove milestone" do
      milestone = create(:budget_investment_milestone, investment: @investment, title: "Title will it remove")

      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link "Delete milestone"

      expect(page).to_not have_content 'Title will it remove'
    end
  end

end
