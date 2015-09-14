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
    expect(page).to have_content proposal.code
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

  scenario 'Create' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'
    expect(page).to have_content 'Help refugees'
    expect(page).to have_content '¿Would you like to give assistance to war refugees?'
    expect(page).to have_content 'This is very important because...'
    expect(page).to have_content 'http://rescue.org/refugees'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)
  end

  scenario 'Responsible name is stored for anonymous users' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'
    expect(Proposal.last.responsible_name).to eq('Isabel Garcia')
  end

  scenario 'Responsible name field is not shown for verified users' do
    author = create(:user, :level_two)
    login_as(author)

    visit new_proposal_path
    expect(page).to_not have_selector('#proposal_responsible_name')

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'
  end

  scenario 'Captcha is required for proposal creation' do
    login_as(create(:user))

    visit new_proposal_path
    fill_in 'proposal_title', with: "Great title"
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: 'Very important issue...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: "wrongText!"
    check 'proposal_terms_of_service'

    click_button "Start a proposal"

    expect(page).to_not have_content "Proposal was successfully created."
    expect(page).to have_content "1 error"

    fill_in 'proposal_captcha', with: correct_captcha_text
    click_button "Start a proposal"

    expect(page).to have_content "Proposal was successfully created."
  end

  scenario 'Failed creation goes back to new showing featured tags' do
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(create(:user))

    visit new_proposal_path
    fill_in 'proposal_title', with: ""
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: 'Very important issue...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button "Start a proposal"

    expect(page).to_not have_content "Proposal was successfully created."
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
    click_button 'Start a proposal'
    expect(page).to have_content error_message
  end

  scenario 'JS injection is prevented but safe html is respected' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing an attack'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: '<p>This is <script>alert("an attack");</script></p>'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'
    expect(page).to have_content 'Testing an attack'
    expect(page.html).to include '<p>This is alert("an attack");</p>'
    expect(page.html).to_not include '<script>alert("an attack");</script>'
    expect(page.html).to_not include '&lt;p&gt;This is'
  end

  scenario 'Autolinking is applied to description' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing auto link'
    fill_in 'proposal_question', with: 'Should I stay or should I go?'
    fill_in 'proposal_description', with: '<p>This is a link www.example.org</p>'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'
    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('www.example.org', href: 'http://www.example.org')
  end

  scenario 'JS injection is prevented but autolinking is respected' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing auto link'
    fill_in 'proposal_question', with: 'Should I stay or should I go?'
    fill_in 'proposal_description', with: "<script>alert('hey')</script> <a href=\"javascript:alert('surprise!')\">click me<a/> http://example.org"
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'
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
      fill_in_ckeditor 'proposal_description', with: 'A description with enough characters'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
      fill_in 'proposal_captcha', with: correct_captcha_text
      check 'proposal_terms_of_service'

      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        find('.js-add-tag-link', text: tag_name).click
      end

      click_button 'Start a proposal'

      expect(page).to have_content 'Proposal was successfully created.'
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        expect(page).to have_content tag_name
      end
    end

    scenario 'using dangerous strings' do
      visit new_proposal_path

      fill_in 'proposal_title', with: 'A test of dangerous strings'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_description', with: 'A description suitable for this test'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
      fill_in 'proposal_captcha', with: correct_captcha_text
      check 'proposal_terms_of_service'

      fill_in 'proposal_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'

      click_button 'Start a proposal'

      expect(page).to have_content 'Proposal was successfully created.'
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
    expect(page).to have_content 'not authorized'
  end

  scenario 'Update should not be posible if proposal is not editable' do
    proposal = create(:proposal)
    Setting.find_by(key: "max_votes_for_proposal_edit").update(value: 10)
    11.times { create(:vote, votable: proposal) }

    expect(proposal).to_not be_editable

    login_as(proposal.author)
    visit edit_proposal_path(proposal)

    expect(current_path).not_to eq(edit_proposal_path(proposal))
    expect(current_path).to eq(proposals_path)
    expect(page).to have_content 'not authorized'
  end

  scenario 'Update should be posible for the author of an editable proposal' do
    proposal = create(:proposal)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    expect(current_path).to eq(edit_proposal_path(proposal))

    fill_in 'proposal_title', with: "End child poverty"
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_description', with: "Let's do something to end child poverty"
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text

    click_button "Save changes"

    expect(page).to have_content "Proposal was successfully updated."
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

    expect(page).to_not have_content "Proposal was successfully updated."
    expect(page).to have_content "error"

    fill_in 'proposal_captcha', with: correct_captcha_text
    click_button "Save changes"

    expect(page).to have_content "Proposal was successfully updated."
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

    expect(page).to_not have_content "Proposal was successfully updated."
    expect(page).to have_content "error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  describe 'Limiting tags shown' do
    scenario 'Index page shows up to 5 tags per proposal' do
      tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa", "Huelgas"]
      create :proposal, tag_list: tag_list

      visit proposals_path

      within('.proposal .tags') do
        expect(page).to have_content '2+'
      end
    end

    scenario 'Index page shows 3 tags with no plus link' do
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

    scenario 'Default order is confidence_score', :js do
      create(:proposal, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:proposal, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:proposal, title: 'Medium proposal').update_column(:confidence_score, 5)

      visit proposals_path

      expect('Best proposal').to appear_before('Medium proposal')
      expect('Medium proposal').to appear_before('Worst proposal')
    end

    scenario 'Proposals are ordered by hot_score', :js do
      create(:proposal, title: 'Best proposal').update_column(:hot_score, 10)
      create(:proposal, title: 'Worst proposal').update_column(:hot_score, 2)
      create(:proposal, title: 'Medium proposal').update_column(:hot_score, 5)

      visit proposals_path
      select 'most active', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="hot_score"]')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=hot_score')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered by most commented', :js do
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

  scenario 'Conflictive' do
    good_proposal = create(:proposal)
    conflictive_proposal = create(:proposal, :conflictive)

    visit proposal_path(conflictive_proposal)
    expect(page).to have_content "This proposal has been flag as innapropiate for some users."

    visit proposal_path(good_proposal)
    expect(page).to_not have_content "This proposal has been flag as innapropiate for some users."
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
end
