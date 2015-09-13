require 'rails_helper'

feature 'Proposals' do

  scenario 'Index' do
    proposal = [create(:proposal), create(:proposal), create(:proposal)]

    visit proposals_path

    expect(page).to have_selector('#proposals .proposal', count: 3)
    proposal.each do |proposal|
      within('#proposals') do
        expect(page).to have_content proposal.title
        expect(page).to have_css("a[href='#{proposal_path(proposal)}']", text: proposal.description)
      end
    end
  end

  scenario 'Paginated Index' do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:proposal) }

    visit proposals_path

    expect(page).to have_selector('#proposals .proposal', count: per_page)

    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).to_not have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_selector('#proposals .proposal', count: 2)
  end

  scenario 'Show' do
    proposal = create(:proposal)

    visit proposal_path(proposal)

    expect(page).to have_content proposal.title
    expect(page).to have_content "Proposal question"
    expect(page).to have_content "Proposal description"
    expect(page).to have_content "http://external_documention.es"
    expect(page).to have_content proposal.author.name
    expect(page).to have_content I18n.l(proposal.created_at.to_date)
    expect(page).to have_selector(avatar(proposal.author.name))

    within('.social-share-button') do
      expect(page.all('a').count).to be(3) # Twitter, Facebook, Google+
    end
  end

  feature 'Proposal index order filters' do

    scenario 'Default order is confidence_score', :js do
      create(:proposal, title: 'Best Proposal').update_column(:confidence_score, 10)
      create(:proposal, title: 'Worst Proposal').update_column(:confidence_score, 2)
      create(:proposal, title: 'Medium Proposal').update_column(:confidence_score, 5)

      visit proposals_path

      expect('Best Proposal').to appear_before('Medium Proposal')
      expect('Medium Proposal').to appear_before('Worst Proposal')
    end

    scenario 'Proposals are ordered by hot_score', :js do
      create(:proposal, title: 'Best Proposal').update_column(:hot_score, 10)
      create(:proposal, title: 'Worst Proposal').update_column(:hot_score, 2)
      create(:proposal, title: 'Medium Proposal').update_column(:hot_score, 5)

      visit proposals_path
      select 'most active', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="hot_score"]')

      within '#proposals' do
        expect('Best Proposal').to appear_before('Medium Proposal')
        expect('Medium Proposal').to appear_before('Worst Proposal')
      end

      expect(current_url).to include('order=hot_score')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered by most commented', :js do
      create(:proposal, title: 'Best Proposal',   comments_count: 10)
      create(:proposal, title: 'Medium Proposal', comments_count: 5)
      create(:proposal, title: 'Worst Proposal',  comments_count: 2)

      visit proposals_path
      select 'most commented', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="most_commented"]')

      within '#proposals' do
        expect('Best Proposal').to appear_before('Medium Proposal')
        expect('Medium Proposal').to appear_before('Worst Proposal')
      end

      expect(current_url).to include('order=most_commented')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered by newest', :js do
      create(:proposal, title: 'Best Proposal',   created_at: Time.now)
      create(:proposal, title: 'Medium Proposal', created_at: Time.now - 1.hour)
      create(:proposal, title: 'Worst Proposal',  created_at: Time.now - 1.day)

      visit proposals_path
      select 'newest', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="created_at"]')

      within '#proposals' do
        expect('Best Proposal').to appear_before('Medium Proposal')
        expect('Medium Proposal').to appear_before('Worst Proposal')
      end

      expect(current_url).to include('order=created_at')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered randomly', :js do
      create_list(:proposal, 12)
      visit proposals_path

      select 'random', from: 'order-selector'
      expect(page).to have_selector('.js-order-selector[data-order="random"]')
      proposals_first_time = find("#proposals").text

      select 'most commented', from: 'order-selector'
      expect(page).to have_selector('.js-order-selector[data-order="most_commented"]')

      select 'random', from: 'order-selector'
      expect(page).to have_selector('.js-order-selector[data-order="random"]')
      proposals_second_time = find("#proposals").text

      expect(proposals_first_time).to_not eq(proposals_second_time)
      expect(current_url).to include('page=1')
    end
  end

  scenario 'proposal index search' do
    proposal1 = create(:proposal, title: "Show me what you got")
    proposal2 = create(:proposal, title: "Get Schwifty")
    proposal3 = create(:proposal)
    proposal4 = create(:proposal, description: "Schwifty in here")
    proposal5 = create(:proposal, question: "Schwifty in here")

    visit proposals_path
    fill_in "search", with: "Schwifty"
    click_button "Search"

    expect(current_path).to eq(proposals_path)

    within("#proposals") do
      expect(page).to have_css('.proposal', count: 3)
      expect(page).to have_content(proposal2.title)
      expect(page).to have_content(proposal4.title)
      expect(page).to have_content(proposal5.title)
      expect(page).to_not have_content(proposal1.title)
      expect(page).to_not have_content(proposal3.title)
    end
  end
end
