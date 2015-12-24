# coding: utf-8
require 'rails_helper'

feature 'Proposals' do
  let!(:subcategory) { create(:subcategory) }
  let(:category) { subcategory.category }

  scenario 'Index' do
    featured_proposals = create_featured_proposals
    proposals = [create(:proposal), create(:proposal), create(:proposal)]

    visit proposals_path

    expect(page).to have_selector('#proposals .proposal-featured', count: 3)
    featured_proposals.each do |featured_proposal|
      within('#featured-proposals') do
        expect(page).to have_content featured_proposal.title
        expect(page).to have_css("a[href='#{proposal_path(featured_proposal)}']")
      end
    end

    expect(page).to have_selector('#proposals .proposal', count: 3)
    proposals.each do |proposal|
      within('#proposals') do
        expect(page).to have_content proposal.title
        expect(page).to have_css("a[href='#{proposal_path(proposal)}']", text: proposal.title)
        expect(page).to have_css("a[href='#{proposal_path(proposal)}']", text: proposal.summary)
      end
    end
  end

  scenario 'Paginated Index' do
    per_page = Kaminari.config.default_per_page
    (per_page + 5).times { create(:proposal) }

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
    expect(page).to have_content proposal.code
    expect(page).to have_content "Proposal question"
    expect(page).to have_content "Proposal description"
    expect(page).to have_content "http://external_documention.es"
    expect(page).to have_content proposal.author.name
    expect(page).to have_content I18n.l(proposal.created_at.to_date)
    expect(page).to have_selector(avatar(proposal.author.name))
    expect(page.html).to include "<title>#{proposal.title}</title>"

    within('.social-share-button') do
      expect(page.all('a').count).to be(3) # Twitter, Facebook, Google+
    end
  end

  scenario 'Social Media Cards' do
    proposal = create(:proposal)

    visit proposal_path(proposal)
    expect(page.html).to include "<meta name=\"twitter:title\" content=\"#{proposal.title}\" />"
    expect(page.html).to include "<meta id=\"ogtitle\" property=\"og:title\" content=\"#{proposal.title}\"/>"
  end

  scenario 'Create', :js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_video_url', with: 'http://youtube.com'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(page).to have_content 'Help refugees'
    expect(page).to have_content '¿Would you like to give assistance to war refugees?'
    expect(page).to have_content 'In summary, what we want is...'
    expect(page).to have_content 'This is very important because...'
    expect(page).to have_content 'http://rescue.org/refugees'
    expect(page).to have_content 'http://youtube.com'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)
  end

  scenario 'Responsible name is stored for anonymous users', :js do
    author = create(:user)

    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(Proposal.last.responsible_name).to eq('Isabel Garcia')
  end

  scenario 'Responsible name field is not shown for verified users', :js do
    author = create(:user, :level_two)
    login_as(author)

    visit new_proposal_path
    expect(page).to_not have_selector('#proposal_responsible_name')

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
  end

  scenario 'Captcha is required for proposal creation', :js do
    login_as(create(:user))

    visit new_proposal_path
    fill_in 'proposal_title', with: "Great title"
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: 'Very important issue...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: "wrongText!"
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button "Create proposal"

    expect(page).to_not have_content "Proposal created successfully."
    expect(page).to have_content "1 error"

    fill_in 'proposal_captcha', with: correct_captcha_text
    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
  end

  scenario 'Failed creation goes back to new showing featured tags', :js do
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(create(:user))

    visit new_proposal_path
    fill_in 'proposal_title', with: ""
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: 'Very important issue...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button "Create proposal"

    expect(page).to_not have_content "Proposal created successfully."
    expect(page).to have_content "error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  scenario 'Errors on create' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    click_button 'Create proposal'
    expect(page).to have_content error_message
  end

  scenario 'JS injection is prevented but safe html is respected', :js do
    author = create(:user)

    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing an attack'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: '<p>This is <script>alert("an attack");</script></p>'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(page).to have_content 'Testing an attack'
    expect(page.html).to include '<p>This is alert("an attack");</p>'
    expect(page.html).to_not include '<script>alert("an attack");</script>'
    expect(page.html).to_not include '&lt;p&gt;This is'
  end

  scenario 'Autolinking is applied to description', :js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing auto link'
    fill_in 'proposal_question', with: 'Should I stay or should I go?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: '<p>This is a link www.example.org</p>'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('www.example.org', href: 'http://www.example.org')
  end

  scenario 'JS injection is prevented but autolinking is respected', :js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing auto link'
    fill_in 'proposal_question', with: 'Should I stay or should I go?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: '<script>alert("hey")</script>http://example.org'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'
    find('li', text: category.name["en"]).click
    find('li', text: subcategory.name["en"]).click

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('http://example.org', href: 'http://example.org')
    expect(page).not_to have_link('click me')
    expect(page.html).to_not include "<script>alert('hey')</script>"

    click_link 'Edit'

    expect(current_path).to eq edit_proposal_path(Proposal.last)
    expect(page).not_to have_link('click me')
    expect(page.html).to_not include "<script>alert('hey')</script>"
  end

  context 'Tagging proposals' do
    let(:author) { create(:user) }

    background do
      login_as(author)
    end

    scenario 'using featured tags', :js do
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        create(:tag, :featured, name: tag_name)
      end

      visit new_proposal_path

      fill_in 'proposal_title', with: 'A test with enough characters'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_summary', with: 'In summary, what we want is...'
      fill_in_ckeditor 'proposal_description', with: 'A description with enough characters'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
      fill_in 'proposal_captcha', with: correct_captcha_text
      check 'proposal_terms_of_service'
      find('li', text: category.name["en"]).click
      find('li', text: subcategory.name["en"]).click

      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        find('.js-add-tag-link', text: tag_name).click
      end

      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        expect(page).to have_content tag_name
      end
    end

    scenario 'using dangerous strings', :js do
      visit new_proposal_path

      fill_in 'proposal_title', with: 'A test of dangerous strings'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_summary', with: 'In summary, what we want is...'
      fill_in_ckeditor 'proposal_description', with: 'A description suitable for this test'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
      fill_in 'proposal_captcha', with: correct_captcha_text
      check 'proposal_terms_of_service'
      find('li', text: category.name["en"]).click
      find('li', text: subcategory.name["en"]).click

      fill_in 'proposal_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'

      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'
      expect(page).to have_content 'user_id1'
      expect(page).to have_content 'a3'
      expect(page).to have_content 'scriptalert("hey");script'
      expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
    end
  end

  scenario 'Update should not be posible if logged user is not the author' do
    proposal = create(:proposal)
    expect(proposal).to be_editable
    login_as(create(:user))

    visit edit_proposal_path(proposal)
    expect(current_path).not_to eq(edit_proposal_path(proposal))
    expect(current_path).to eq(proposals_path)
    expect(page).to have_content 'You do not have permission'
  end

  scenario 'Update should not be posible if proposal is not editable' do
    proposal = create(:proposal)
    Setting["max_votes_for_proposal_edit"] = 10
    11.times { create(:vote, votable: proposal) }

    expect(proposal).to_not be_editable

    login_as(proposal.author)
    visit edit_proposal_path(proposal)

    expect(current_path).not_to eq(edit_proposal_path(proposal))
    expect(current_path).to eq(proposals_path)
    expect(page).to have_content 'You do not have permission'
  end

  scenario 'Update should be posible for the author of an editable proposal', :js do
    proposal = create(:proposal)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    expect(current_path).to eq(edit_proposal_path(proposal))

    fill_in 'proposal_title', with: "End child poverty"
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'Basically...'
    fill_in_ckeditor 'proposal_description', with: "Let\\'s do something to end child poverty"
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text

    click_button "Save changes"

    expect(page).to have_content "Proposal updated successfully."
    expect(page).to have_content "Basically..."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's do something to end child poverty"
  end

  scenario 'Errors on update' do
    proposal = create(:proposal)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    fill_in 'proposal_title', with: ""
    click_button "Save changes"

    expect(page).to have_content error_message
  end

  scenario 'Captcha is required to update a proposal' do
    proposal = create(:proposal)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    expect(current_path).to eq(edit_proposal_path(proposal))

    fill_in 'proposal_title', with: "New cool title"
    fill_in 'proposal_captcha', with: "wrong!"
    click_button "Save changes"

    expect(page).to_not have_content "Proposal updated successfully."
    expect(page).to have_content "error"

    fill_in 'proposal_captcha', with: correct_captcha_text
    click_button "Save changes"

    expect(page).to have_content "Proposal updated successfully."
  end

  scenario 'Failed update goes back to edit showing featured tags' do
    proposal       = create(:proposal)
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    expect(current_path).to eq(edit_proposal_path(proposal))

    fill_in 'proposal_title', with: ""
    fill_in 'proposal_captcha', with: correct_captcha_text
    click_button "Save changes"

    expect(page).to_not have_content "Proposal updated successfully."
    expect(page).to have_content "error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  describe 'Limiting tags shown' do
    scenario 'Index page shows up to 5 tags per proposal' do
      create_featured_proposals
      tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
      create :proposal, tag_list: tag_list

      visit proposals_path

      within('.proposal .tags') do
        expect(page).to have_content '1+'
      end
    end

    scenario 'Index page shows 3 tags with no plus link' do
      create_featured_proposals
      tag_list = ["Medio Ambiente", "Corrupción", "Fiestas populares"]
      create :proposal, tag_list: tag_list

      visit proposals_path

      within('.proposal .tags') do
        tag_list.each do |tag|
          expect(page).to have_content tag
        end
        expect(page).not_to have_content '+'
      end
    end
  end

  feature 'Proposal index order filters' do

    scenario 'Default order is hot_score', :js do
      create_featured_proposals

      create(:proposal, title: 'Best proposal').update_column(:hot_score, 10)
      create(:proposal, title: 'Worst proposal').update_column(:hot_score, 2)
      create(:proposal, title: 'Medium proposal').update_column(:hot_score, 5)

      visit proposals_path

      expect('Best proposal').to appear_before('Medium proposal')
      expect('Medium proposal').to appear_before('Worst proposal')
    end

    scenario 'Proposals are ordered by confidence_score', :js do
      create_featured_proposals

      create(:proposal, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:proposal, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:proposal, title: 'Medium proposal').update_column(:confidence_score, 5)

      visit proposals_path
      select 'highest rated', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="confidence_score"]')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered by most commented', :js do
      create_featured_proposals

      create(:proposal, title: 'Best proposal',   comments_count: 10)
      create(:proposal, title: 'Medium proposal', comments_count: 5)
      create(:proposal, title: 'Worst proposal',  comments_count: 2)

      visit proposals_path
      select 'most commented', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="most_commented"]')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=most_commented')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered by newest', :js do
      create_featured_proposals

      create(:proposal, title: 'Best proposal',   created_at: Time.now)
      create(:proposal, title: 'Medium proposal', created_at: Time.now - 1.hour)
      create(:proposal, title: 'Worst proposal',  created_at: Time.now - 1.day)

      visit proposals_path
      select 'newest', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="created_at"]')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=created_at')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered randomly', :js do
      create_featured_proposals

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

  scenario 'Proposal index search' do
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

  scenario "Order by relevance by default", :js do
    proposal1 = create(:proposal, title: "Show you got",      cached_votes_up: 10)
    proposal2 = create(:proposal, title: "Show what you got", cached_votes_up: 1)
    proposal3 = create(:proposal, title: "Show you got",      cached_votes_up: 100)

    visit proposals_path
    fill_in "search", with: "Show what you got"
    click_button "Search"

    expect(page).to have_selector('.js-order-selector[data-order="relevance"]')

    within("#proposals") do
      expect(all(".proposal")[0].text).to match "Show what you got"
      expect(all(".proposal")[1].text).to match "Show you got"
      expect(all(".proposal")[2].text).to match "Show you got"
    end
  end

  scenario "Reorder results maintaing search", :js do
    proposal1 = create(:proposal, title: "Show you got",      cached_votes_up: 10,  created_at: 1.week.ago)
    proposal2 = create(:proposal, title: "Show what you got", cached_votes_up: 1,   created_at: 1.month.ago)
    proposal3 = create(:proposal, title: "Show you got",      cached_votes_up: 100, created_at: Time.now)
    proposal4 = create(:proposal, title: "Do not display",    cached_votes_up: 1,   created_at: 1.week.ago)

    visit proposals_path
    fill_in "search", with: "Show what you got"
    click_button "Search"

    select 'newest', from: 'order-selector'
    expect(page).to have_selector('.js-order-selector[data-order="created_at"]')

    within("#proposals") do
      expect(all(".proposal")[0].text).to match "Show you got"
      expect(all(".proposal")[1].text).to match "Show you got"
      expect(all(".proposal")[2].text).to match "Show what you got"
      expect(page).to_not have_content "Do not display"
    end
  end

  scenario 'Index search does not show featured proposals' do
    featured_proposals = create_featured_proposals
    proposal = create(:proposal, title: "Abcdefghi")

    visit proposals_path
    fill_in "search", with: proposal.title
    click_button "Search"

    expect(page).to_not have_selector('#proposals .proposal-featured')
    expect(page).to_not have_selector('#featured-proposals')
  end

  scenario 'Index tag does not show featured proposals' do
    featured_proposals = create_featured_proposals
    proposal = create(:proposal, tag_list: "123")

    visit proposals_path(tag: "123")

    expect(page).to_not have_selector('#proposals .proposal-featured')
    expect(page).to_not have_selector('#featured-proposals')
  end

  scenario 'Conflictive' do
    good_proposal = create(:proposal)
    conflictive_proposal = create(:proposal, :conflictive)

    visit proposal_path(conflictive_proposal)
    expect(page).to have_content "This proposal has been flagged as inappropriate by several users."

    visit proposal_path(good_proposal)
    expect(page).to_not have_content "This proposal has been flagged as inappropriate by several users."
  end

  scenario "Flagging", :js do
    user = create(:user)
    proposal = create(:proposal)

    login_as(user)
    visit proposal_path(proposal)

    within "#proposal_#{proposal.id}" do
      page.find("#flag-expand-proposal-#{proposal.id}").click
      page.find("#flag-proposal-#{proposal.id}").click

      expect(page).to have_css("#unflag-expand-proposal-#{proposal.id}")
    end

    expect(Flag.flagged?(user, proposal)).to be
  end

  scenario "Unflagging", :js do
    user = create(:user)
    proposal = create(:proposal)
    Flag.flag(user, proposal)

    login_as(user)
    visit proposal_path(proposal)

    within "#proposal_#{proposal.id}" do
      page.find("#unflag-expand-proposal-#{proposal.id}").click
      page.find("#unflag-proposal-#{proposal.id}").click

      expect(page).to have_css("#flag-expand-proposal-#{proposal.id}")
    end

    expect(Flag.flagged?(user, proposal)).to_not be
  end

  scenario 'Erased author' do
    user = create(:user)
    proposal = create(:proposal, author: user)
    user.erase

    visit proposals_path
    expect(page).to have_content('User deleted')

    visit proposal_path(proposal)
    expect(page).to have_content('User deleted')

    create_featured_proposals

    visit proposals_path
    expect(page).to have_content('User deleted')
  end
end
