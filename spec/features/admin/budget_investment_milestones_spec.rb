require 'rails_helper'

feature 'Admin budget investment milestones' do

  background do
    admin = create(:administrator)
    login_as(admin.user)

    @investment = create(:budget_investment)
  end

  it_behaves_like "translatable",
                  "budget_investment_milestone",
                  "edit_admin_budget_budget_investment_budget_investment_milestone_path",
                  %w[description]

  context "Index" do
    scenario 'Displaying milestones' do
      milestone = create(:budget_investment_milestone, investment: @investment)
      create(:image, imageable: milestone)
      document = create(:document, documentable: milestone)

      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      expect(page).to have_content("Milestone")
      expect(page).to have_content(milestone.title)
      expect(page).to have_content(milestone.id)
      expect(page).to have_content(milestone.publication_date.to_date)
      expect(page).to have_content(milestone.status.name)
      expect(page).to have_link 'Show image'
      expect(page).to have_link document.title
    end

    scenario 'Displaying no_milestones text' do
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      expect(page).to have_content("Milestone")
      expect(page).to have_content("Don't have defined milestones")
    end
  end

  context "New" do
    scenario "Add milestone" do
      status = create(:budget_investment_status)
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link 'Create new milestone'

      select status.name, from: 'budget_investment_milestone_status_id'
      fill_in 'budget_investment_milestone_description_en', with: 'New description milestone'
      fill_in 'budget_investment_milestone_publication_date', with: Date.current

      click_button 'Create milestone'

      expect(page).to have_content 'New description milestone'
      expect(page).to have_content Date.current
      expect(page).to have_content status.name
    end

    scenario "Status select is disabled if there are no statuses available" do
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link 'Create new milestone'
      expect(find("#budget_investment_milestone_status_id").disabled?).to be true
    end

    scenario "Show validation errors on milestone form" do
      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link 'Create new milestone'

      fill_in 'budget_investment_milestone_description_en', with: 'New description milestone'

      click_button 'Create milestone'

      within "#new_budget_investment_milestone" do
        expect(page).to have_content "can't be blank", count: 1
        expect(page).to have_content 'New description milestone'
      end
    end
  end

  context "Edit" do
    scenario "Change title, description and document names" do
      milestone = create(:budget_investment_milestone, investment: @investment)
      create(:image, imageable: milestone)
      document = create(:document, documentable: milestone)

      visit admin_budget_budget_investment_path(@investment.budget, @investment)
      expect(page).to have_link document.title

      click_link milestone.title

      expect(page).to have_css("img[alt='#{milestone.image.title}']")

      fill_in 'budget_investment_milestone_description_en', with: 'Changed description'
      fill_in 'budget_investment_milestone_publication_date', with: Date.current
      fill_in 'budget_investment_milestone_documents_attributes_0_title', with: 'New document title'

      click_button 'Update milestone'

      expect(page).to have_content 'Changed description'
      expect(page).to have_content Date.current
      expect(page).to have_link 'Show image'
      expect(page).to have_link 'New document title'
    end
  end

  context "Delete" do
    scenario "Remove milestone" do
      milestone = create(:budget_investment_milestone, investment: @investment, title: "Title will it remove")

      visit admin_budget_budget_investment_path(@investment.budget, @investment)

      click_link "Delete milestone"

      expect(page).not_to have_content 'Title will it remove'
    end
  end

end
