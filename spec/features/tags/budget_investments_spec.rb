require 'rails_helper'

feature 'Tags' do

  let(:author)  { create(:user, :level_two, username: 'Isabel') }
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:group)   { create(:budget_group, name: "Health", budget: budget) }
  let!(:heading) { create(:budget_heading, name: "More hospitals", group: group) }

  scenario 'Index' do
    earth = create(:budget_investment, heading: heading, tag_list: 'Medio Ambiente')
    money = create(:budget_investment, heading: heading, tag_list: 'Economía')

    visit budget_investments_path(budget, heading_id: heading.id)

    within "#budget_investment_#{earth.id}" do
      expect(page).to have_content "Medio Ambiente"
    end

    within "#budget_investment_#{money.id}" do
      expect(page).to have_content "Economía"
    end
  end

  scenario 'Index shows 3 tags with no plus link' do
    tag_list = ["Medio Ambiente", "Corrupción", "Fiestas populares"]
    create :budget_investment, heading: heading, tag_list: tag_list

    visit budget_investments_path(budget, heading_id: heading.id)

    within('.budget-investment .tags') do
      tag_list.each do |tag|
        expect(page).to have_content tag
      end
      expect(page).not_to have_content '+'
    end
  end

  scenario 'Index shows up to 5 tags per proposal' do
    create_featured_proposals
    tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
    create :budget_investment, heading: heading, tag_list: tag_list

    visit budget_investments_path(budget, heading_id: heading.id)

    within('.budget-investment .tags') do
      expect(page).to have_content '1+'
    end
  end

  scenario 'Show' do
    investment = create(:budget_investment, heading: heading, tag_list: 'Hacienda, Economía')

    visit budget_investment_path(budget, investment)

    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
  end

  scenario 'Create with custom tags' do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    select  'Health: More hospitals', from: 'budget_investment_heading_id'
    fill_in 'budget_investment_title', with: 'Build a skyscraper'
    fill_in 'budget_investment_description', with: 'I want to live in a high tower over the clouds'
    check   'budget_investment_terms_of_service'

    fill_in 'budget_investment_tag_list', with: 'Economía, Hacienda'

    click_button 'Create Investment'

    expect(page).to have_content 'Investment created successfully.'
    expect(page).to have_content 'Economía'
    expect(page).to have_content 'Hacienda'
  end

  scenario 'Category with category tags', :js do
    login_as(author)

    education = create(:tag, :category, name: 'Education')
    health    = create(:tag, :category, name: 'Health')

    visit new_budget_investment_path(budget_id: budget.id)

    select  'Health: More hospitals', from: 'budget_investment_heading_id'
    fill_in 'budget_investment_title', with: 'Build a skyscraper'
    fill_in_ckeditor 'budget_investment_description', with: 'If I had a gym near my place I could go do Zumba'
    check 'budget_investment_terms_of_service'

    find('.js-add-tag-link', text: 'Education').click
    click_button 'Create Investment'

    expect(page).to have_content 'Investment created successfully.'

    within "#tags_budget_investment_#{Budget::Investment.last.id}" do
      expect(page).to have_content 'Education'
      expect(page).to_not have_content 'Health'
    end
  end

  scenario 'Create with too many tags' do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    select  'Health: More hospitals', from: 'budget_investment_heading_id'
    fill_in 'budget_investment_title', with: 'Build a skyscraper'
    fill_in 'budget_investment_description', with: 'I want to live in a high tower over the clouds'
    check   'budget_investment_terms_of_service'

    fill_in 'budget_investment_tag_list', with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button 'Create Investment'

    expect(page).to have_content error_message
    expect(page).to have_content 'tags must be less than or equal to 6'
  end

  scenario 'Create with dangerous strings' do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    select  'Health: More hospitals', from: 'budget_investment_heading_id'
    fill_in 'budget_investment_title', with: 'Build a skyscraper'
    fill_in 'budget_investment_description', with: 'I want to live in a high tower over the clouds'
    check   'budget_investment_terms_of_service'

    fill_in 'budget_investment_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'

    click_button 'Create Investment'

    expect(page).to have_content 'Investment created successfully.'
    expect(page).to have_content 'user_id1'
    expect(page).to have_content 'a3'
    expect(page).to have_content 'scriptalert("hey");script'
    expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
  end

  context "Filter" do

    scenario "From index" do

      investment1 = create(:budget_investment, heading: heading, tag_list: 'Education')
      investment2 = create(:budget_investment, heading: heading, tag_list: 'Health')

      visit budget_investments_path(budget, heading_id: heading.id)

      within "#budget_investment_#{investment1.id}" do
        click_link "Education"
      end

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)
        expect(page).to have_content(investment1.title)
      end
    end

    scenario "From show" do
      investment1 = create(:budget_investment, heading: heading, tag_list: 'Education')
      investment2 = create(:budget_investment, heading: heading, tag_list: 'Health')

      visit budget_investment_path(budget, investment1)

      click_link "Education"

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)
        expect(page).to have_content(investment1.title)
      end
    end

  end

  context 'Tag cloud' do

    let!(:investment1) { create(:budget_investment, heading: heading, tag_list: 'Medio Ambiente') }
    let!(:investment2) { create(:budget_investment, heading: heading, tag_list: 'Medio Ambiente') }
    let!(:investment3) { create(:budget_investment, heading: heading, tag_list: 'Economía') }

    scenario 'Display user tags' do
      Budget::PHASES.each do |phase|
        budget.update(phase: phase)

        visit budget_investments_path(budget, heading_id: heading.id)

        within "#tag-cloud" do
          expect(page).to have_content "Medio Ambiente"
          expect(page).to have_content "Economía"
        end
      end
    end

    scenario "Filter by user tags" do
      Budget::PHASES.each do |phase|
        budget.update(phase: phase)

        if budget.balloting?
          [investment1, investment2, investment3].each do |investment|
            investment.update(selected: true, feasibility: "feasible")
          end
        end

        visit budget_path(budget)
        click_link group.name

        within "#tag-cloud" do
          click_link "Medio Ambiente"
        end

        expect(page).to have_css ".budget-investment", count: 2
        expect(page).to have_content investment1.title
        expect(page).to have_content investment2.title
        expect(page).to_not have_content investment3.title
      end
    end

  end

  context "Categories" do

    let!(:tag1) { create(:tag, :category, name: 'Medio Ambiente') }
    let!(:tag2) { create(:tag, :category, name: 'Economía') }

    let!(:investment1) { create(:budget_investment, heading: heading, tag_list: 'Medio Ambiente') }
    let!(:investment2) { create(:budget_investment, heading: heading, tag_list: 'Medio Ambiente') }
    let!(:investment3) { create(:budget_investment, heading: heading, tag_list: 'Economía') }

    scenario 'Display category tags' do
      Budget::PHASES.each do |phase|
        budget.update(phase: phase)

        visit budget_investments_path(budget, heading_id: heading.id)

        within "#categories" do
          expect(page).to have_content "Medio Ambiente"
          expect(page).to have_content "Economía"
        end
      end
    end

    scenario "Filter by category tags" do
      Budget::PHASES.each do |phase|
        budget.update(phase: phase)

        if budget.balloting?
          [investment1, investment2, investment3].each do |investment|
            investment.update(selected: true, feasibility: "feasible")
          end
        end

        visit budget_path(budget)
        click_link group.name

        within "#categories" do
          click_link "Medio Ambiente"
        end

        expect(page).to have_css ".budget-investment", count: 2
        expect(page).to have_content investment1.title
        expect(page).to have_content investment2.title
        expect(page).to_not have_content investment3.title
      end
    end
  end

  context "Valuation" do

    scenario "Users do not see valuator tags" do
      investment = create(:budget_investment, heading: heading, tag_list: 'Park')
      investment.set_tag_list_on(:valuation, 'Education')
      investment.save

      visit budget_investment_path(budget, investment)

      expect(page).to     have_content 'Park'
      expect(page).to_not have_content 'Education'
    end

    scenario "Valuators do not see user tags" do
      investment = create(:budget_investment, heading: heading, tag_list: 'Park')
      investment.set_tag_list_on(:valuation, 'Education')
      investment.save

      admin = create(:administrator)
      login_as(admin.user)

      visit admin_budget_budget_investment_path(budget, investment)
      click_link 'Edit classification'

      expect(page).to     have_content 'Education'
      expect(page).to_not have_content 'Park'
    end

  end
end