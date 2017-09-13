require 'rails_helper'

feature 'Budget Investments' do

  let(:author)  { create(:user, :level_two, username: 'Isabel') }
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:other_budget) { create(:budget, name: "What a Budget!") }
  let(:group) { create(:budget_group, name: "Health", budget: budget) }
  let!(:heading) { create(:budget_heading, name: "More hospitals", group: group) }

  scenario 'Index' do
    investments = [create(:budget_investment, heading: heading),
                   create(:budget_investment, heading: heading),
                   create(:budget_investment, :feasible, heading: heading)]

    unfeasible_investment = create(:budget_investment, :unfeasible, heading: heading)

    visit budget_path(budget)
    click_link "Health"

    expect(page).to have_selector('#budget-investments .budget-investment', count: 3)
    investments.each do |investment|
      within('#budget-investments') do
        expect(page).to have_content investment.title
        expect(page).to have_css("a[href='#{budget_investment_path(budget_id: budget.id, id: investment.id)}']", text: investment.title)
        expect(page).to_not have_content(unfeasible_investment.title)
      end
    end
  end

  scenario 'Index should show investment descriptive image only when is defined' do
    investment = create(:budget_investment, heading: heading)
    investment_with_image = create(:budget_investment, heading: heading)
    image = create(:image, imageable: investment_with_image)

    visit budget_investments_path(budget, heading_id: heading.id)

    within("#budget_investment_#{investment.id}") do
      expect(page).to have_css("div.no-image")
    end
    within("#budget_investment_#{investment_with_image.id}") do
      expect(page).to have_css("img[alt='#{investment_with_image.image.title}']")
    end
  end

  context("Search") do

    scenario 'Search by text' do
      investment1 = create(:budget_investment, heading: heading, title: "Get Schwifty")
      investment2 = create(:budget_investment, heading: heading, title: "Schwifty Hello")
      investment3 = create(:budget_investment, heading: heading, title: "Do not show me")

      visit budget_investments_path(budget, heading_id: heading.id)

      within(".expanded #search_form") do
        fill_in "search", with: "Schwifty"
        click_button "Search"
      end

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 2)

        expect(page).to have_content(investment1.title)
        expect(page).to have_content(investment2.title)
        expect(page).to_not have_content(investment3.title)
      end
    end

  end

  context("Filters") do

    scenario 'by unfeasibility' do
      investment1 = create(:budget_investment, :unfeasible, heading: heading, valuation_finished: true)
      investment2 = create(:budget_investment, :feasible, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, :feasible, heading: heading)

      visit budget_investments_path(budget_id: budget.id, heading_id: heading.id, filter: "unfeasible")

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)

        expect(page).to have_content(investment1.title)
        expect(page).to_not have_content(investment2.title)
        expect(page).to_not have_content(investment3.title)
        expect(page).to_not have_content(investment4.title)
      end
    end

    scenario "by unfeasibilty link for group with one heading" do
      budget.update(phase: :balloting)
      group   = create(:budget_group,   name: 'All City', budget: budget)
      heading = create(:budget_heading, name: "Madrid",   group: group)

      visit budget_path(budget)
      click_link 'See unfeasible investments'

      click_link "All City"

      expected_path = budget_investments_path(budget, heading_id: heading.id, filter: "unfeasible")
      expect(page).to have_current_path(expected_path)
    end

    scenario "by unfeasibilty link for group with many headings" do
      budget.update(phase: :balloting)
      group = create(:budget_group, name: 'Districts', budget: budget)
      heading1 = create(:budget_heading, name: 'Carabanchel', group: group)
      heading2 = create(:budget_heading, name: 'Barajas',     group: group)

      visit budget_path(budget)

      click_link 'See unfeasible investments'

      click_link 'Districts'
      click_link 'Carabanchel'

      expected_path = budget_investments_path(budget, heading_id: heading1.id, filter: "unfeasible")
      expect(page).to have_current_path(expected_path)
    end
  end

  context("Orders") do
    before(:each) { budget.update(phase: 'selecting') }

    scenario "Default order is random" do
      per_page = Kaminari.config.default_per_page
      (per_page + 100).times { create(:budget_investment) }

      visit budget_investments_path(budget, heading_id: heading.id)
      order = all(".budget-investment h3").collect {|i| i.text }

      visit budget_investments_path(budget, heading_id: heading.id)
      new_order = eq(all(".budget-investment h3").collect {|i| i.text })

      expect(order).to_not eq(new_order)
    end

    scenario "Random order after another order" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:budget_investment) }

      visit budget_investments_path(budget, heading_id: heading.id)
      click_link "highest rated"
      click_link "random"

      order = all(".budget-investment h3").collect {|i| i.text }

      visit budget_investments_path(budget, heading_id: heading.id)
      new_order = eq(all(".budget-investment h3").collect {|i| i.text })

      expect(order).to_not eq(new_order)
    end

    scenario 'Random order maintained with pagination', :js do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:budget_investment, heading: heading) }

      visit budget_investments_path(budget, heading_id: heading.id)

      order = all(".budget-investment h3").collect {|i| i.text }

      click_link 'Next'
      expect(page).to have_content "You're on page 2"

      click_link 'Previous'
      expect(page).to have_content "You're on page 1"

      new_order = all(".budget-investment h3").collect {|i| i.text }
      expect(order).to eq(new_order)
    end

    scenario 'Proposals are ordered by confidence_score', :js do
      create(:budget_investment, heading: heading, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:budget_investment, heading: heading, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:budget_investment, heading: heading, title: 'Medium proposal').update_column(:confidence_score, 5)

      visit budget_investments_path(budget, heading_id: heading.id)
      click_link 'highest rated'
      expect(page).to have_selector('a.active', text: 'highest rated')

      within '#budget-investments' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

  end

  context 'Phase I - Accepting' do
    before(:each) { budget.update(phase: 'accepting') }

    scenario 'Create with invisible_captcha honeypot field' do
      login_as(author)
      visit new_budget_investment_path(budget_id: budget.id)

      select  'Health: More hospitals', from: 'budget_investment_heading_id'
      fill_in 'budget_investment_title', with: 'I am a bot'
      fill_in 'budget_investment_subtitle', with: 'This is the honeypot'
      fill_in 'budget_investment_description', with: 'This is the description'
      check   'budget_investment_terms_of_service'

      click_button 'Create Investment'

      expect(page.status_code).to eq(200)
      expect(page.html).to be_empty
      expect(current_path).to eq(budget_investments_path(budget_id: budget.id))
    end

    scenario 'Create budget investment too fast' do
      allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

      login_as(author)
      visit new_budget_investment_path(budget_id: budget.id)

      select  'Health: More hospitals', from: 'budget_investment_heading_id'
      fill_in 'budget_investment_title', with: 'I am a bot'
      fill_in 'budget_investment_description', with: 'This is the description'
      check   'budget_investment_terms_of_service'

      click_button 'Create Investment'

      expect(page).to have_content 'Sorry, that was too quick! Please resubmit'
      expect(current_path).to eq(new_budget_investment_path(budget_id: budget.id))
    end

    scenario 'Create' do
      login_as(author)

      visit new_budget_investment_path(budget_id: budget.id)

      select  'Health: More hospitals', from: 'budget_investment_heading_id'
      fill_in 'budget_investment_title', with: 'Build a skyscraper'
      fill_in 'budget_investment_description', with: 'I want to live in a high tower over the clouds'
      fill_in 'budget_investment_external_url', with: 'http://http://skyscraperpage.com/'
      fill_in 'budget_investment_location', with: 'City center'
      fill_in 'budget_investment_organization_name', with: 'T.I.A.'
      fill_in 'budget_investment_tag_list', with: 'Towers'
      check   'budget_investment_terms_of_service'

      click_button 'Create Investment'

      expect(page).to have_content 'Investment created successfully'
      expect(page).to have_content 'Build a skyscraper'
      expect(page).to have_content 'I want to live in a high tower over the clouds'
      expect(page).to have_content 'http://http://skyscraperpage.com/'
      expect(page).to have_content 'City center'
      expect(page).to have_content 'T.I.A.'
      expect(page).to have_content 'Towers'

      visit user_url(author, filter: :budget_investments)
      expect(page).to have_content '1 Investment'
      expect(page).to have_content 'Build a skyscraper'
    end

    scenario 'Errors on create' do
      login_as(author)

      visit new_budget_investment_path(budget_id: budget.id)
      click_button 'Create Investment'
      expect(page).to have_content error_message
    end

    context 'Suggest' do
      factory = :budget_investment

      scenario 'Show up to 5 suggestions', :js do
        login_as(author)

        %w(first second third fourth fifth sixth).each do |ordinal|
          create(factory, title: "#{ordinal.titleize} #{factory}, has search term", budget: budget)
        end
        create(factory, title: "This is the last #{factory}", budget: budget)

        visit new_budget_investment_path(budget)
        fill_in "budget_investment_title", with: "search"

        within("div#js-suggest") do
          expect(page).to have_content "You are seeing 5 of 6 investments containing the term 'search'"
        end
      end

      scenario 'No found suggestions', :js do
        login_as(author)

        %w(first second third fourth fifth sixth).each do |ordinal|
          create(factory, title: "#{ordinal.titleize} #{factory}, has search term", budget: budget)
        end

        visit new_budget_investment_path(budget)
        fill_in "budget_investment_title", with: "item"

        within('div#js-suggest') do
          expect(page).to_not have_content 'You are seeing'
        end
      end

      scenario "Don't show suggestions from a different budget", :js do
        login_as(author)

        %w(first second third fourth fifth sixth).each do |ordinal|
          create(factory, title: "#{ordinal.titleize} #{factory}, has search term", budget: budget)
        end

        visit new_budget_investment_path(other_budget)
        fill_in "budget_investment_title", with: "search"

        within('div#js-suggest') do
          expect(page).to_not have_content 'You are seeing'
        end
      end
    end

    scenario 'Ballot is not visible' do
      login_as(author)

      visit budget_investments_path(budget, heading_id: heading.id)

      expect(page).to_not have_link('Check my ballot')
      expect(page).to_not have_css('#progress_bar')
      within('#sidebar') do
        expect(page).to_not have_content('My ballot')
      end
    end
  end

  scenario "Show" do
    user = create(:user)
    login_as(user)

    investment = create(:budget_investment, heading: heading)

    visit budget_investment_path(budget_id: budget.id, id: investment.id)

    expect(page).to have_content(investment.title)
    expect(page).to have_content(investment.description)
    expect(page).to have_content(investment.author.name)
    expect(page).to have_content(investment.heading.name)
    within("#investment_code") do
      expect(page).to have_content(investment.id)
    end
  end

  scenario 'Can access the community' do
    Setting['feature.community'] = true

    investment = create(:budget_investment, heading: heading)
    visit budget_investment_path(budget_id: budget.id, id: investment.id)
    expect(page).to have_content "Access the community"

    Setting['feature.community'] = false
  end

  scenario 'Can not access the community' do
    Setting['feature.community'] = false

    investment = create(:budget_investment, heading: heading)
    visit budget_investment_path(budget_id: budget.id, id: investment.id)
    expect(page).not_to have_content "Access the community"
  end

  scenario "Don't display flaggable buttons" do
    investment = create(:budget_investment, heading: heading)

    visit budget_investment_path(budget_id: budget.id, id: investment.id)

    expect(page).not_to have_selector ".js-follow"
  end

  scenario "Show back link contains heading id" do
    investment = create(:budget_investment, heading: heading)
    visit budget_investment_path(budget, investment)

    expect(page).to have_link "Go back", href: budget_investments_path(budget, heading_id: investment.heading)
  end

  context "Show (feasible budget investment)" do
    let(:investment) do
      create(:budget_investment,
             :feasible,
             :finished,
             budget: budget,
             group: group,
             heading: heading,
             price: 16,
             price_explanation: 'Every wheel is 4 euros, so total is 16')
    end

    background do
      user = create(:user)
      login_as(user)
    end

    scenario "Budget in selecting phase" do
      budget.update(phase: "selecting")
      visit budget_investment_path(budget_id: budget.id, id: investment.id)

      expect(page).to_not have_content("Unfeasibility explanation")
      expect(page).to_not have_content("Price explanation")
      expect(page).to_not have_content(investment.price_explanation)
    end

    scenario "Budget in balloting phase" do
      budget.update(phase: "balloting")
      visit budget_investment_path(budget_id: budget.id, id: investment.id)

      expect(page).to have_content("Price explanation")
      expect(page).to have_content(investment.price_explanation)
    end
  end

  scenario "Show (unfeasible budget investment)" do
    user = create(:user)
    login_as(user)

    investment = create(:budget_investment,
                        :unfeasible,
                        :finished,
                        budget: budget,
                        group: group,
                        heading: heading,
                        unfeasibility_explanation: 'Local government is not competent in this matter')

    visit budget_investment_path(budget_id: budget.id, id: investment.id)

    expect(page).to have_content("Unfeasibility explanation")
    expect(page).to have_content(investment.unfeasibility_explanation)
  end

  scenario "Show milestones", :js do
    user = create(:user)
    investment = create(:budget_investment)
    milestone = create(:budget_investment_milestone, investment: investment, title: "New text to show",
                                                     created_at: DateTime.new(2015, 9, 19).utc)

    login_as(user)
    visit budget_investment_path(budget_id: investment.budget.id, id: investment.id)

    find("#tab-milestones-label").trigger('click')

    within("#tab-milestones") do
      expect(page).to have_content(milestone.title)
      expect(page).to have_content(milestone.description)
      expect(page).to have_content("Published 2015-09-19")
    end
  end

  scenario "Show no_milestones text", :js do
    user = create(:user)
    investment = create(:budget_investment)

    login_as(user)
    visit budget_investment_path(budget_id: investment.budget.id, id: investment.id)

    find("#tab-milestones-label").trigger('click')

    within("#tab-milestones") do
      expect(page).to have_content("Don't have defined milestones")
    end
  end

  it_behaves_like "followable", "budget_investment", "budget_investment_path", { "budget_id": "budget_id", "id": "id" }

  it_behaves_like "imageable", "budget_investment", "budget_investment_path", { "budget_id": "budget_id", "id": "id" }

  it_behaves_like "nested imageable",
                  "budget_investment",
                  "new_budget_investment_path",
                  { "budget_id": "budget_id" },
                  "imageable_fill_new_valid_budget_investment",
                  "Create Investment",
                  "Budget Investment created successfully."

  it_behaves_like "documentable", "budget_investment", "budget_investment_path", { "budget_id": "budget_id", "id": "id" }

  it_behaves_like "nested documentable",
                  "user",
                  "budget_investment",
                  "new_budget_investment_path",
                  { "budget_id": "budget_id" },
                  "documentable_fill_new_valid_budget_investment",
                  "Create Investment",
                  "Budget Investment created successfully."

  it_behaves_like "mappable",
                  "budget_investment",
                  "investment",
                  "new_budget_investment_path",
                  "",
                  "budget_investment_path",
                  { "budget_id": "budget_id" }

  context "Destroy" do

    scenario "Admin cannot destroy budget investments" do
      admin = create(:administrator)
      user = create(:user, :level_two)
      investment = create(:budget_investment, heading: heading, author: user)

      login_as(admin.user)
      visit user_path(user)

      within("#budget_investment_#{investment.id}") do
        expect(page).to_not have_link "Delete"
      end
    end

    scenario "Author can destroy while on the accepting phase" do
      user = create(:user, :level_two)
      sp1 = create(:budget_investment, heading: heading, price: 10000, author: user)

      login_as(user)
      visit user_path(user, tab: :budget_investments)

      within("#budget_investment_#{sp1.id}") do
        expect(page).to have_content(sp1.title)
        click_link('Delete')
      end

      visit user_path(user, tab: :budget_investments)
    end
  end

  context "Selecting Phase" do

    background do
      budget.update(phase: "selecting")
    end

    context "Popup alert to vote only in one heading per group" do

      scenario "When supporting in the first heading group", :js do
        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, :selected, heading: carabanchel)
        salamanca_investment   = create(:budget_investment, :selected, heading: salamanca)

        visit budget_investments_path(budget, heading_id: carabanchel.id)

        within("#budget_investment_#{carabanchel_investment.id}") do
          expect(page).to have_css(".in-favor a[data-confirm]")
        end
      end

      scenario "When already supported in the group", :js do
        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        salamanca_investment   = create(:budget_investment, heading: salamanca)

        create(:vote, votable: carabanchel_investment, voter: author)

        login_as(author)
        visit budget_investments_path(budget, heading_id: carabanchel.id)

        within("#budget_investment_#{carabanchel_investment.id}") do
          expect(page).to_not have_css(".in-favor a[data-confirm]")
        end
      end

      scenario "When supporting in another group", :js do
        carabanchel     = create(:budget_heading, group: group)
        another_heading = create(:budget_heading, group: create(:budget_group, budget: budget))

        carabanchel_investment   = create(:budget_investment, heading: carabanchel)
        another_group_investment = create(:budget_investment, heading: another_heading)

        create(:vote, votable: carabanchel_investment, voter: author)

        login_as(author)
        visit budget_investments_path(budget, heading_id: another_heading.id)

        within("#budget_investment_#{another_group_investment.id}") do
          expect(page).to have_css(".in-favor a[data-confirm]")
        end
      end
    end

    scenario "Sidebar in show should display support text" do
      investment = create(:budget_investment, budget: budget)
      visit budget_investment_path(budget, investment)

      within("aside") do
        expect(page).to have_content "Supports"
      end
    end

  end

  context "Evaluating Phase" do

    background do
      budget.update(phase: "valuating")
    end

    scenario "Sidebar in show should display support text and count" do
      investment = create(:budget_investment, :selected, budget: budget)
      create(:vote, votable: investment)

      visit budget_investment_path(budget, investment)

      within("aside") do
        expect(page).to have_content "Supports"
        expect(page).to have_content "1 support"
      end
    end

    scenario "Index should display support count" do
      investment = create(:budget_investment, budget: budget, heading: heading)
      create(:vote, votable: investment)

      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        expect(page).to have_content "1 support"
      end
    end

    scenario "Show should display support text and count" do
      investment = create(:budget_investment, budget: budget, heading: heading)
      create(:vote, votable: investment)

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        expect(page).to have_content "Supports"
        expect(page).to have_content "1 support"
      end
    end

  end

  context "Balloting Phase" do

    background do
      budget.update(phase: "balloting")
    end

    scenario "Index" do
      user = create(:user, :level_two)
      sp1 = create(:budget_investment, :selected, heading: heading, price: 10000)
      sp2 = create(:budget_investment, :selected, heading: heading, price: 20000)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link budget.name
      click_link "Health"

      within("#budget_investment_#{sp1.id}") do
        expect(page).to have_content sp1.title
        expect(page).to have_content "€10,000"
      end

      within("#budget_investment_#{sp2.id}") do
        expect(page).to have_content sp2.title
        expect(page).to have_content "€20,000"
      end
    end

    scenario 'Order by cost (only when balloting)' do
      create(:budget_investment, :selected, heading: heading, title: 'Build a nice house', price: 1000).update_column(:confidence_score, 10)
      create(:budget_investment, :selected, heading: heading, title: 'Build an ugly house', price: 1000).update_column(:confidence_score, 5)
      create(:budget_investment, :selected, heading: heading, title: 'Build a skyscraper', price: 20000)

      visit budget_investments_path(budget, heading_id: heading.id)

      click_link 'by price'
      expect(page).to have_selector('a.active', text: 'by price')

      within '#budget-investments' do
        expect('Build a skyscraper').to appear_before('Build a nice house')
        expect('Build a nice house').to appear_before('Build an ugly house')
      end

      expect(current_url).to include('order=price')
      expect(current_url).to include('page=1')
    end

    scenario "Show" do
      user = create(:user, :level_two)
      sp1 = create(:budget_investment, :selected, heading: heading, price: 10000)

      login_as(user)
      visit budget_investments_path(budget, heading_id: heading.id)

      click_link sp1.title

      expect(page).to have_content "€10,000"
    end

    scenario "Sidebar in show should display vote text" do
      investment = create(:budget_investment, :selected, budget: budget)
      visit budget_investment_path(budget, investment)

      within("aside") do
        expect(page).to have_content "Votes"
      end
    end

    scenario "Confirm", :js do
      budget.update(phase: 'balloting')
      user = create(:user, :level_two)

      global_group   = create(:budget_group, budget: budget, name: 'Global Group')
      global_heading = create(:budget_heading, group: global_group, name: 'Global Heading')

      carabanchel_heading = create(:budget_heading, group: group, name: "Carabanchel")
      new_york_heading    = create(:budget_heading, group: group, name: "New York")

      sp1 = create(:budget_investment, :selected, price: 1, heading: global_heading)
      sp2 = create(:budget_investment, :selected, price: 10, heading: global_heading)
      sp3 = create(:budget_investment, :selected, price: 100, heading: global_heading)
      sp4 = create(:budget_investment, :selected, price: 1000, heading: carabanchel_heading)
      sp5 = create(:budget_investment, :selected, price: 10000, heading: carabanchel_heading)
      sp6 = create(:budget_investment, :selected, price: 100000, heading: new_york_heading)

      login_as(user)
      visit budget_path(budget)

      click_link "Global Group"
      # No need to click_link "Global Heading" because the link of a group with a single heading
      # points to the list of investments directly

      add_to_ballot(sp1)
      add_to_ballot(sp2)

      visit budget_path(budget)

      click_link "Health"
      click_link "Carabanchel"

      add_to_ballot(sp4)
      add_to_ballot(sp5)

      visit budget_ballot_path(budget)

      expect(page).to have_content "You can change your vote at any time until the close of this phase"

      within("#budget_group_#{global_group.id}") do
        expect(page).to have_content sp1.title
        expect(page).to have_content sp1.price

        expect(page).to have_content sp2.title
        expect(page).to have_content sp2.price

        expect(page).to_not have_content sp3.title
        expect(page).to_not have_content sp3.price
      end

      within("#budget_group_#{group.id}") do
        expect(page).to have_content sp4.title
        expect(page).to have_content "€1,000"

        expect(page).to have_content sp5.title
        expect(page).to have_content "€10,000"

        expect(page).to_not have_content sp6.title
        expect(page).to_not have_content "€100,000"
      end
    end

    scenario 'Ballot is visible' do
      login_as(author)

      visit budget_investments_path(budget, heading_id: heading.id)

      expect(page).to have_link('Check my ballot')
      expect(page).to have_css('#progress_bar')
      within('#sidebar') do
        expect(page).to have_content('My ballot')
      end
    end

    scenario 'Show unselected budget investments' do
      investment1 = create(:budget_investment, :unselected, :feasible, heading: heading, valuation_finished: true)
      investment2 = create(:budget_investment, :selected,   :feasible, heading: heading, valuation_finished: true)
      investment3 = create(:budget_investment, :selected,   :feasible, heading: heading, valuation_finished: true)
      investment4 = create(:budget_investment, :selected,   :feasible, heading: heading, valuation_finished: true)

      visit budget_investments_path(budget_id: budget.id, heading_id: heading.id, filter: "unselected")

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)

        expect(page).to have_content(investment1.title)
        expect(page).to_not have_content(investment2.title)
        expect(page).to_not have_content(investment3.title)
        expect(page).to_not have_content(investment4.title)
      end
    end

    scenario "Shows unselected link for group with one heading" do
      group   = create(:budget_group,   name: 'All City', budget: budget)
      heading = create(:budget_heading, name: "Madrid",   group: group)

      visit budget_path(budget)
      click_link 'See investments not selected for balloting phase'

      click_link "All City"

      expected_path = budget_investments_path(budget, heading_id: heading.id, filter: "unselected")
      expect(page).to have_current_path(expected_path)
    end

    scenario "Shows unselected link for group with many headings" do
      group = create(:budget_group, name: 'Districts', budget: budget)
      heading1 = create(:budget_heading, name: 'Carabanchel', group: group)
      heading2 = create(:budget_heading, name: 'Barajas',     group: group)

      visit budget_path(budget)

      click_link 'See investments not selected for balloting phase'

      click_link 'Districts'
      click_link 'Carabanchel'

      expected_path = budget_investments_path(budget, heading_id: heading1.id, filter: "unselected")
      expect(page).to have_current_path(expected_path)
    end

    scenario "Do not display vote button for unselected investments in index" do
      investment = create(:budget_investment, :unselected, heading: heading)

      visit budget_investments_path(budget_id: budget.id, heading_id: heading.id, filter: "unselected")

      expect(page).to have_content investment.title
      expect(page).to_not have_link("Vote")
    end

    scenario "Do not display vote button for unselected investments in show" do
      investment = create(:budget_investment, :unselected, heading: heading)

      visit budget_investment_path(budget, investment)

      expect(page).to have_content investment.title
      expect(page).to_not have_link("Vote")
    end

    feature "Reclassification" do

      scenario "Due to heading change" do
        user = create(:user, :level_two)
        investment = create(:budget_investment, :selected, heading: heading)
        heading2 = create(:budget_heading, group: group)

        ballot = create(:budget_ballot, user: user, budget: budget)
        ballot.investments << investment

        login_as(user)
        visit budget_ballot_path(budget)

        expect(page).to have_content("You have voted one investment")

        investment.heading = heading2
        investment.save

        visit budget_ballot_path(budget)

        expect(page).to have_content("You have voted 0 investment")
      end

      scenario "Due to being unfeasible" do
        user = create(:user, :level_two)
        investment = create(:budget_investment, :selected, heading: heading)
        heading2 = create(:budget_heading, group: group)

        ballot = create(:budget_ballot, user: user, budget: budget)
        ballot.investments << investment

        login_as(user)
        visit budget_ballot_path(budget)

        expect(page).to have_content("You have voted one investment")

        investment.feasibility = "unfeasible"
        investment.unfeasibility_explanation = "too expensive"
        investment.save

        visit budget_ballot_path(budget)

        expect(page).to have_content("You have voted 0 investment")
      end

    end
  end
end
