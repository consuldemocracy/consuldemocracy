# coding: utf-8
require 'rails_helper'

feature 'Proposals' do

  context 'Index' do
    scenario 'Lists featured and regular proposals' do
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
          expect(page).to have_content proposal.summary
          expect(page).to have_css("a[href='#{proposal_path(proposal)}']", text: proposal.title)
        end
      end
    end

    scenario 'Pagination' do
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

    scenario 'Index should show proposal descriptive image only when is defined' do
      featured_proposals = create_featured_proposals
      proposal = create(:proposal)
      proposal_with_image = create(:proposal)
      image = create(:image, imageable: proposal_with_image)

      visit proposals_path(proposal)

      within("#proposal_#{proposal.id}") do
        expect(page).to have_css("div.no-image")
      end
      within("#proposal_#{proposal_with_image.id}") do
        expect(page).to have_css("img[alt='#{proposal_with_image.image.title}']")
      end
    end
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
    expect(page).not_to have_selector ".js-flag-actions"
    expect(page).not_to have_selector ".js-follow"

    within('.social-share-button') do
      expect(page.all('a').count).to be(4) # Twitter, Facebook, Google+, Telegram
    end
  end

  context "Show" do
    scenario 'When path matches the friendly url' do
      proposal = create(:proposal)

      right_path = proposal_path(proposal)
      visit right_path

      expect(current_path).to eq(right_path)
    end

    scenario 'When path does not match the friendly url' do
      proposal = create(:proposal)

      right_path = proposal_path(proposal)
      old_path = "#{proposals_path}/#{proposal.id}-something-else"
      visit old_path

      expect(current_path).to_not eq(old_path)
      expect(current_path).to eq(right_path)
    end

    scenario 'Can access the community' do
      Setting['feature.community'] = true

      proposal = create(:proposal)
      visit proposal_path(proposal)
      expect(page).to have_content "Access the community"

      Setting['feature.community'] = false
    end

    scenario 'Can not access the community' do
      Setting['feature.community'] = false

      proposal = create(:proposal)
      visit proposal_path(proposal)
      expect(page).not_to have_content "Access the community"
    end
  end

  context "Embedded video" do

    scenario "Show YouTube video" do
      proposal = create(:proposal, video_url: "http://www.youtube.com/watch?v=a7UFm6ErMPU")
      visit proposal_path(proposal)
      expect(page).to have_selector("div[id='js-embedded-video']")
      expect(page.html).to include 'https://www.youtube.com/embed/a7UFm6ErMPU'
    end

    scenario "Show Vimeo video" do
      proposal = create(:proposal, video_url: "https://vimeo.com/7232823")
      visit proposal_path(proposal)
      expect(page).to have_selector("div[id='js-embedded-video']")
      expect(page.html).to include 'https://player.vimeo.com/video/7232823'
    end

    scenario "Dont show video" do
      proposal = create(:proposal, video_url: nil)

      visit proposal_path(proposal)
      expect(page).to_not have_selector("div[id='js-embedded-video']")
    end
  end

  scenario 'Social Media Cards' do
    proposal = create(:proposal)

    visit proposal_path(proposal)
    expect(page.html).to include "<meta name=\"twitter:title\" content=\"#{proposal.title}\" />"
    expect(page.html).to include "<meta id=\"ogtitle\" property=\"og:title\" content=\"#{proposal.title}\"/>"
  end

  scenario 'Create' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=yPQfcG-eimk'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_tag_list', with: 'Refugees, Solidarity'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(page).to have_content 'Help refugees'
    expect(page).not_to have_content 'You can also see more information about improving your campaign'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'Help refugees'
    expect(page).to have_content '¿Would you like to give assistance to war refugees?'
    expect(page).to have_content 'In summary, what we want is...'
    expect(page).to have_content 'This is very important because...'
    expect(page).to have_content 'http://rescue.org/refugees'
    expect(page).to have_content 'https://www.youtube.com/watch?v=yPQfcG-eimk'
    expect(page).to have_content author.name
    expect(page).to have_content 'Refugees'
    expect(page).to have_content 'Solidarity'
    expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)
  end

  scenario 'Create with proposal improvement info link' do
    Setting['proposal_improvement_path'] = '/more-information/proposal-improvement'
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=yPQfcG-eimk'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_tag_list', with: 'Refugees, Solidarity'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'
    expect(page).to have_content 'Improve your campaign and get more supports'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'Help refugees'

    Setting['proposal_improvement_path'] = nil
  end

  scenario 'Create with invisible_captcha honeypot field' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'I am a bot'
    fill_in 'proposal_subtitle', with: 'This is the honeypot field'
    fill_in 'proposal_question', with: 'This is a question'
    fill_in 'proposal_summary', with: 'This is the summary'
    fill_in 'proposal_description', with: 'This is the description'
    fill_in 'proposal_external_url', with: 'http://google.com/robots.txt'
    fill_in 'proposal_responsible_name', with: 'Some other robot'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(current_path).to eq(proposals_path)
  end

  scenario 'Create proposal too fast' do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'I am a bot'
    fill_in 'proposal_question', with: 'This is a question'
    fill_in 'proposal_summary', with: 'This is the summary'
    fill_in 'proposal_description', with: 'This is the description'
    fill_in 'proposal_external_url', with: 'http://google.com/robots.txt'
    fill_in 'proposal_responsible_name', with: 'Some other robot'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Sorry, that was too quick! Please resubmit'

    expect(current_path).to eq(new_proposal_path)
  end

  scenario 'Responsible name is stored for anonymous users' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(Proposal.last.responsible_name).to eq('Isabel Garcia')
  end

  scenario 'Responsible name field is not shown for verified users' do
    author = create(:user, :level_two)
    login_as(author)

    visit new_proposal_path
    expect(page).to_not have_selector('#proposal_responsible_name')

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'
    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(Proposal.last.responsible_name).to eq(author.document_number)
  end

  scenario 'Errors on create' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    click_button 'Create proposal'

    expect(page).to have_content error_message
  end

  scenario 'JS injection is prevented but safe html is respected' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing an attack'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: '<p>This is <script>alert("an attack");</script></p>'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

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
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: '<p>This is a link www.example.org</p>'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('www.example.org', href: 'http://www.example.org')
  end

  scenario 'JS injection is prevented but autolinking is respected' do
    author = create(:user)
    js_injection_string = "<script>alert('hey')</script> <a href=\"javascript:alert('surprise!')\">click me<a/> http://example.org"
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing auto link'
    fill_in 'proposal_question', with: 'Should I stay or should I go?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: js_injection_string
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('http://example.org', href: 'http://example.org')
    expect(page).not_to have_link('click me')
    expect(page.html).to_not include "<script>alert('hey')</script>"

    click_link 'Edit'

    expect(current_path).to eq edit_proposal_path(Proposal.last)
    expect(page).not_to have_link('click me')
    expect(page.html).to_not include "<script>alert('hey')</script>"
  end

  context 'Geozones' do

    scenario "Default whole city" do
      author = create(:user)
      login_as(author)

      visit new_proposal_path

      fill_in 'proposal_title', with: 'Help refugees'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_summary', with: 'In summary, what we want is...'
      fill_in 'proposal_description', with: 'This is very important because...'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=yPQfcG-eimk'
      fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
      check 'proposal_terms_of_service'

      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'

      click_link 'Not now, go to my proposal'

      within "#geozone" do
        expect(page).to have_content 'All city'
      end
    end

    scenario "Specific geozone" do
      geozone = create(:geozone, name: 'California')
      geozone = create(:geozone, name: 'New York')
      author = create(:user)
      login_as(author)

      visit new_proposal_path

      fill_in 'proposal_title', with: 'Help refugees'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_summary', with: 'In summary, what we want is...'
      fill_in 'proposal_description', with: 'This is very important because...'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=yPQfcG-eimk'
      fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
      check 'proposal_terms_of_service'

      select('California', from: 'proposal_geozone_id')
      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'

      click_link 'Not now, go to my proposal'

      within "#geozone" do
        expect(page).to have_content 'California'
      end
    end

  end

  context 'Retired proposals' do
    scenario 'Retire' do
      proposal = create(:proposal)
      login_as(proposal.author)

      visit user_path(proposal.author)
      within("#proposal_#{proposal.id}") do
        click_link 'Retire'
      end
      expect(current_path).to eq(retire_form_proposal_path(proposal))

      select 'Duplicated', from: 'proposal_retired_reason'
      fill_in 'proposal_retired_explanation', with: 'There are three other better proposals with the same subject'
      click_button "Retire proposal"

      expect(page).to have_content "Proposal retired"

      visit proposal_path(proposal)

      expect(page).to have_content proposal.title
      expect(page).to have_content 'Proposal retired by the author'
      expect(page).to have_content 'Duplicated'
      expect(page).to have_content 'There are three other better proposals with the same subject'
    end

    scenario 'Fields are mandatory' do
      proposal = create(:proposal)
      login_as(proposal.author)

      visit retire_form_proposal_path(proposal)

      click_button 'Retire proposal'

      expect(page).to_not have_content 'Proposal retired'
      expect(page).to have_content "can't be blank", count: 2
    end

    scenario 'Index do not list retired proposals by default' do
      create_featured_proposals
      not_retired = create(:proposal)
      retired = create(:proposal, retired_at: Time.current)

      visit proposals_path

      expect(page).to have_selector('#proposals .proposal', count: 1)
      within('#proposals') do
        expect(page).to have_content not_retired.title
        expect(page).to_not have_content retired.title
      end
    end

    scenario 'Index has a link to retired proposals list' do
      create_featured_proposals
      not_retired = create(:proposal)
      retired = create(:proposal, retired_at: Time.current)

      visit proposals_path

      expect(page).to_not have_content retired.title
      click_link 'Proposals retired by the author'

      expect(page).to have_content retired.title
      expect(page).to_not have_content not_retired.title
    end

    scenario 'Retired proposals index interface elements' do
      visit proposals_path(retired: 'all')

      expect(page).to_not have_content 'Advanced search'
      expect(page).to_not have_content 'Categories'
      expect(page).to_not have_content 'Districts'
    end

    scenario 'Retired proposals index has links to filter by retired_reason' do
      unfeasible = create(:proposal, retired_at: Time.current, retired_reason: 'unfeasible')
      duplicated = create(:proposal, retired_at: Time.current, retired_reason: 'duplicated')

      visit proposals_path(retired: 'all')

      expect(page).to have_content unfeasible.title
      expect(page).to have_content duplicated.title
      expect(page).to have_link 'Duplicated'
      expect(page).to have_link 'Underway'
      expect(page).to have_link 'Unfeasible'
      expect(page).to have_link 'Done'
      expect(page).to have_link 'Other'

      click_link 'Unfeasible'

      expect(page).to have_content unfeasible.title
      expect(page).to_not have_content duplicated.title
    end
  end

  scenario 'Update should not be posible if logged user is not the author' do
    proposal = create(:proposal)
    expect(proposal).to be_editable
    login_as(create(:user))

    visit edit_proposal_path(proposal)
    expect(current_path).not_to eq(edit_proposal_path(proposal))
    expect(current_path).to eq(root_path)
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
    expect(current_path).to eq(root_path)
    expect(page).to have_content 'You do not have permission'
    Setting["max_votes_for_proposal_edit"] = 1000
  end

  scenario 'Update should be posible for the author of an editable proposal' do
    proposal = create(:proposal)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    expect(current_path).to eq(edit_proposal_path(proposal))

    fill_in 'proposal_title', with: "End child poverty"
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'Basically...'
    fill_in 'proposal_description', with: "Let's do something to end child poverty"
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'

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
      click_link 'highest rated'
      expect(page).to have_selector('a.active', text: 'highest rated')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

    scenario 'Proposals are ordered by newest', :js do
      create_featured_proposals

      create(:proposal, title: 'Best proposal',   created_at: Time.current)
      create(:proposal, title: 'Medium proposal', created_at: Time.current - 1.hour)
      create(:proposal, title: 'Worst proposal',  created_at: Time.current - 1.day)

      visit proposals_path
      click_link 'newest'
      expect(page).to have_selector('a.active', text: 'newest')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=created_at')
      expect(current_url).to include('page=1')
    end

    context 'Recommendations' do

      before do
        Setting['feature.user.recommendations'] = true
        create(:proposal, title: 'Best',   cached_votes_up: 10, tag_list: "Sport")
        create(:proposal, title: 'Medium', cached_votes_up: 5, tag_list: "Sport")
        create(:proposal, title: 'Worst',  cached_votes_up: 1, tag_list: "Sport")
      end

      after do
        Setting['feature.user.recommendations'] = nil
      end

      scenario 'Proposals can not ordered by recommendations when there is not an user logged', :js do
        visit proposals_path

        expect(page).not_to have_selector('a', text: 'recommendations')
      end

      scenario 'Should display text when there are not recommendeds results', :js do
        user = create(:user)
        proposal = create(:proposal, tag_list: "Distinct_to_sport")
        create(:follow, followable: proposal, user: user)
        login_as(user)
        visit proposals_path

        click_link 'recommendations'

        expect(page).to have_content "There are not proposals related to your interests"
      end

      scenario 'Should display text when user has not related interests', :js do
        user = create(:user)
        login_as(user)
        visit proposals_path

        click_link 'recommendations'

        expect(page).to have_content "Follow proposals so we can give you recommendations"
      end

      scenario 'Proposals are ordered by recommendations when there is an user logged', :js do
        user = create(:user)
        proposal = create(:proposal, tag_list: "Sport")
        create(:follow, followable: proposal, user: user)
        login_as(user)

        visit proposals_path

        click_link 'recommendations'

        expect(page).to have_selector('a.active', text: 'recommendations')

        within '#proposals-list' do
          expect('Best').to appear_before('Medium')
          expect('Medium').to appear_before('Worst')
        end

        expect(current_url).to include('order=recommendations')
        expect(current_url).to include('page=1')
      end
    end
  end

  feature 'Archived proposals' do

    scenario 'show on archived tab' do
      create_featured_proposals
      archived_proposals = create_archived_proposals

      visit proposals_path
      click_link 'Archived'

      within("#proposals-list") do
        archived_proposals.each do |proposal|
          expect(page).to have_content(proposal.title)
        end
      end
    end

    scenario 'do not show in other index tabs' do
      create_featured_proposals
      archived_proposal = create(:proposal, :archived)

      visit proposals_path

      within("#proposals-list") do
        expect(page).to_not have_content archived_proposal.title
      end

      orders = %w{hot_score confidence_score created_at relevance}
      orders.each do |order|
        visit proposals_path(order: order)

        within("#proposals-list") do
          expect(page).to_not have_content archived_proposal.title
        end
      end
    end

    scenario 'do not show support buttons in index' do
      create_featured_proposals
      archived_proposals = create_archived_proposals

      visit proposals_path(order: 'archival_date')

      within("#proposals-list") do
        archived_proposals.each do |proposal|
          within("#proposal_#{proposal.id}_votes") do
            expect(page).to have_content "This proposal has been archived and can't collect supports"
          end
        end
      end
    end

    scenario 'do not show support buttons in show' do
      archived_proposal = create(:proposal, :archived)

      visit proposal_path(archived_proposal)
      expect(page).to have_content "This proposal has been archived and can't collect supports"
    end

    scenario 'do not show in featured proposals section' do
      featured_proposal = create(:proposal, :with_confidence_score, cached_votes_up: 100)
      archived_proposal = create(:proposal, :archived, :with_confidence_score, cached_votes_up: 10000)

      visit proposals_path

      within("#featured-proposals") do
        expect(page).to have_content(featured_proposal.title)
        expect(page).to_not have_content(archived_proposal.title)
      end
      within("#proposals-list") do
        expect(page).to_not have_content(featured_proposal.title)
        expect(page).to_not have_content(archived_proposal.title)
      end

      click_link "Archived"

      within("#featured-proposals") do
        expect(page).to have_content(featured_proposal.title)
        expect(page).to_not have_content(archived_proposal.title)
      end
      within("#proposals-list") do
        expect(page).to_not have_content(featured_proposal.title)
        expect(page).to have_content(archived_proposal.title)
      end
    end

    scenario "Order by votes" do
      create(:proposal, :archived, title: "Least voted").update_column(:confidence_score, 10)
      create(:proposal, :archived, title: "Most voted").update_column(:confidence_score, 50)
      create(:proposal, :archived, title: "Some votes").update_column(:confidence_score, 25)

      visit proposals_path
      click_link 'Archived'

      within("#proposals-list") do
        expect(all(".proposal")[0].text).to match "Most voted"
        expect(all(".proposal")[1].text).to match "Some votes"
        expect(all(".proposal")[2].text).to match "Least voted"
      end
    end

  end

  context "Search" do

    context "Basic search" do

      scenario 'Search by text' do
        proposal1 = create(:proposal, title: "Get Schwifty")
        proposal2 = create(:proposal, title: "Schwifty Hello")
        proposal3 = create(:proposal, title: "Do not show me")

        visit proposals_path

        within(".expanded #search_form") do
          fill_in "search", with: "Schwifty"
          click_button "Search"
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 2)

          expect(page).to have_content(proposal1.title)
          expect(page).to have_content(proposal2.title)
          expect(page).to_not have_content(proposal3.title)
        end
      end

      scenario 'Search by proposal code' do
        proposal1 = create(:proposal, title: "Get Schwifty")
        proposal2 = create(:proposal, title: "Schwifty Hello")

        visit proposals_path

        within(".expanded #search_form") do
          fill_in "search", with: proposal1.code
          click_button "Search"
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 1)

          expect(page).to have_content(proposal1.title)
          expect(page).to_not have_content(proposal2.title)
        end
      end

      scenario "Maintain search criteria" do
        visit proposals_path

        within(".expanded #search_form") do
          fill_in "search", with: "Schwifty"
          click_button "Search"
        end

        expect(page).to have_selector("input[name='search'][value='Schwifty']")
      end

    end

    context "Advanced search" do

      scenario "Search by text", :js do
        proposal1 = create(:proposal, title: "Get Schwifty")
        proposal2 = create(:proposal, title: "Schwifty Hello")
        proposal3 = create(:proposal, title: "Do not show me")

        visit proposals_path

        click_link "Advanced search"
        fill_in "Write the text", with: "Schwifty"
        click_button "Filter"

        expect(page).to have_content("There are 2 citizen proposals")

        within("#proposals") do

          expect(page).to have_content(proposal1.title)
          expect(page).to have_content(proposal2.title)
          expect(page).to_not have_content(proposal3.title)
        end
      end

      context "Search by author type" do

        scenario "Public employee", :js do
          ana = create :user, official_level: 1
          john = create :user, official_level: 2

          proposal1 = create(:proposal, author: ana)
          proposal2 = create(:proposal, author: ana)
          proposal3 = create(:proposal, author: john)

          visit proposals_path

          click_link "Advanced search"
          select Setting['official_level_1_name'], from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("There are 2 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to_not have_content(proposal3.title)
          end
        end

        scenario "Municipal Organization", :js do
          ana = create :user, official_level: 2
          john = create :user, official_level: 3

          proposal1 = create(:proposal, author: ana)
          proposal2 = create(:proposal, author: ana)
          proposal3 = create(:proposal, author: john)

          visit proposals_path

          click_link "Advanced search"
          select Setting['official_level_2_name'], from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("There are 2 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to_not have_content(proposal3.title)
          end
        end

        scenario "General director", :js do
          ana = create :user, official_level: 3
          john = create :user, official_level: 4

          proposal1 = create(:proposal, author: ana)
          proposal2 = create(:proposal, author: ana)
          proposal3 = create(:proposal, author: john)

          visit proposals_path

          click_link "Advanced search"
          select Setting['official_level_3_name'], from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("There are 2 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to_not have_content(proposal3.title)
          end
        end

        scenario "City councillor", :js do
          ana = create :user, official_level: 4
          john = create :user, official_level: 5

          proposal1 = create(:proposal, author: ana)
          proposal2 = create(:proposal, author: ana)
          proposal3 = create(:proposal, author: john)

          visit proposals_path

          click_link "Advanced search"
          select Setting['official_level_4_name'], from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("There are 2 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to_not have_content(proposal3.title)
          end
        end

        scenario "Mayoress", :js do
          ana = create :user, official_level: 5
          john = create :user, official_level: 4

          proposal1 = create(:proposal, author: ana)
          proposal2 = create(:proposal, author: ana)
          proposal3 = create(:proposal, author: john)

          visit proposals_path

          click_link "Advanced search"
          select Setting['official_level_5_name'], from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("There are 2 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to_not have_content(proposal3.title)
          end
        end

      end

      context "Search by date" do

        context "Predefined date ranges" do

          scenario "Last day", :js do
            proposal1 = create(:proposal, created_at: 1.minute.ago)
            proposal2 = create(:proposal, created_at: 1.hour.ago)
            proposal3 = create(:proposal, created_at: 2.days.ago)

            visit proposals_path

            click_link "Advanced search"
            select "Last 24 hours", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("There are 2 citizen proposals")

            within("#proposals") do
              expect(page).to have_content(proposal1.title)
              expect(page).to have_content(proposal2.title)
              expect(page).to_not have_content(proposal3.title)
            end
          end

          scenario "Last week", :js do
            proposal1 = create(:proposal, created_at: 1.day.ago)
            proposal2 = create(:proposal, created_at: 5.days.ago)
            proposal3 = create(:proposal, created_at: 8.days.ago)

            visit proposals_path

            click_link "Advanced search"
            select "Last week", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("There are 2 citizen proposals")

            within("#proposals") do
              expect(page).to have_content(proposal1.title)
              expect(page).to have_content(proposal2.title)
              expect(page).to_not have_content(proposal3.title)
            end
          end

          scenario "Last month", :js do
            proposal1 = create(:proposal, created_at: 10.days.ago)
            proposal2 = create(:proposal, created_at: 20.days.ago)
            proposal3 = create(:proposal, created_at: 33.days.ago)

            visit proposals_path

            click_link "Advanced search"
            select "Last month", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("There are 2 citizen proposals")

            within("#proposals") do
              expect(page).to have_content(proposal1.title)
              expect(page).to have_content(proposal2.title)
              expect(page).to_not have_content(proposal3.title)
            end
          end

          scenario "Last year", :js do
            proposal1 = create(:proposal, created_at: 300.days.ago)
            proposal2 = create(:proposal, created_at: 350.days.ago)
            proposal3 = create(:proposal, created_at: 370.days.ago)

            visit proposals_path

            click_link "Advanced search"
            select "Last year", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("There are 2 citizen proposals")

            within("#proposals") do
              expect(page).to have_content(proposal1.title)
              expect(page).to have_content(proposal2.title)
              expect(page).to_not have_content(proposal3.title)
            end
          end

        end

        scenario "Search by custom date range", :js do
          proposal1 = create(:proposal, created_at: 2.days.ago)
          proposal2 = create(:proposal, created_at: 3.days.ago)
          proposal3 = create(:proposal, created_at: 9.days.ago)

          visit proposals_path

          click_link "Advanced search"
          select "Customized", from: "js-advanced-search-date-min"
          fill_in "advanced_search_date_min", with: 7.days.ago
          fill_in "advanced_search_date_max", with: 1.day.ago
          click_button "Filter"

          expect(page).to have_content("There are 2 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to_not have_content(proposal3.title)
          end
        end

        scenario "Search by custom invalid date range", :js do
          proposal1 = create(:proposal, created_at: 2.days.ago)
          proposal2 = create(:proposal, created_at: 3.days.ago)
          proposal3 = create(:proposal, created_at: 9.days.ago)

          visit proposals_path

          click_link "Advanced search"
          select "Customized", from: "js-advanced-search-date-min"
          fill_in "advanced_search_date_min", with: 4000.years.ago
          fill_in "advanced_search_date_max", with: "wrong date"
          click_button "Filter"

          expect(page).to have_content("There are 3 citizen proposals")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
            expect(page).to have_content(proposal2.title)
            expect(page).to have_content(proposal3.title)
          end
        end

        scenario "Search by multiple filters", :js do
          ana  = create :user, official_level: 1
          john = create :user, official_level: 1

          proposal1 = create(:proposal, title: "Get Schwifty",   author: ana,  created_at: 1.minute.ago)
          proposal2 = create(:proposal, title: "Hello Schwifty", author: john, created_at: 2.days.ago)
          proposal3 = create(:proposal, title: "Save the forest")

          visit proposals_path

          click_link "Advanced search"
          fill_in "Write the text", with: "Schwifty"
          select Setting['official_level_1_name'], from: "advanced_search_official_level"
          select "Last 24 hours", from: "js-advanced-search-date-min"

          click_button "Filter"

          expect(page).to have_content("There is 1 citizen proposal")

          within("#proposals") do
            expect(page).to have_content(proposal1.title)
          end
        end

        scenario "Maintain advanced search criteria", :js do
          visit proposals_path
          click_link "Advanced search"

          fill_in "Write the text", with: "Schwifty"
          select Setting['official_level_1_name'], from: "advanced_search_official_level"
          select "Last 24 hours", from: "js-advanced-search-date-min"

          click_button "Filter"

          expect(page).to have_content("citizen proposals cannot be found")

          within "#js-advanced-search" do
            expect(page).to have_selector("input[name='search'][value='Schwifty']")
            expect(page).to have_select('advanced_search[official_level]', selected: Setting['official_level_1_name'])
            expect(page).to have_select('advanced_search[date_min]', selected: 'Last 24 hours')
          end
        end

        scenario "Maintain custom date search criteria", :js do
          visit proposals_path
          click_link "Advanced search"

          select "Customized", from: "js-advanced-search-date-min"
          fill_in "advanced_search_date_min", with: 7.days.ago.to_date
          fill_in "advanced_search_date_max", with: 1.day.ago.to_date
          click_button "Filter"

          expect(page).to have_content("citizen proposals cannot be found")

          within "#js-advanced-search" do
            expect(page).to have_select('advanced_search[date_min]', selected: 'Customized')
            expect(page).to have_selector("input[name='advanced_search[date_min]'][value*='#{7.days.ago.strftime('%Y-%m-%d')}']")
            expect(page).to have_selector("input[name='advanced_search[date_max]'][value*='#{1.day.ago.strftime('%Y-%m-%d')}']")
          end
        end

      end
    end

    scenario "Order by relevance by default", :js do
      proposal1 = create(:proposal, title: "Show you got",      cached_votes_up: 10)
      proposal2 = create(:proposal, title: "Show what you got", cached_votes_up: 1)
      proposal3 = create(:proposal, title: "Show you got",      cached_votes_up: 100)

      visit proposals_path
      fill_in "search", with: "Show what you got"
      click_button "Search"

      expect(page).to have_selector("a.active", text: "relevance")

      within("#proposals") do
        expect(all(".proposal")[0].text).to match "Show what you got"
        expect(all(".proposal")[1].text).to match "Show you got"
        expect(all(".proposal")[2].text).to match "Show you got"
      end
    end

    scenario "Reorder results maintaing search", :js do
      proposal1 = create(:proposal, title: "Show you got",      cached_votes_up: 10,  created_at: 1.week.ago)
      proposal2 = create(:proposal, title: "Show what you got", cached_votes_up: 1,   created_at: 1.month.ago)
      proposal3 = create(:proposal, title: "Show you got",      cached_votes_up: 100, created_at: Time.current)
      proposal4 = create(:proposal, title: "Do not display",    cached_votes_up: 1,   created_at: 1.week.ago)

      visit proposals_path
      fill_in "search", with: "Show what you got"
      click_button "Search"
      click_link 'newest'
      expect(page).to have_selector("a.active", text: "newest")

      within("#proposals") do
        expect(all(".proposal")[0].text).to match "Show you got"
        expect(all(".proposal")[1].text).to match "Show you got"
        expect(all(".proposal")[2].text).to match "Show what you got"
        expect(page).to_not have_content "Do not display"
      end
    end

    scenario "Reorder by recommendations results maintaing search", :js do
      Setting['feature.user.recommendations'] = true
      user = create(:user)
      login_as(user)
      proposal1 = create(:proposal, title: "Show you got",      cached_votes_up: 10,  tag_list: "Sport")
      proposal2 = create(:proposal, title: "Show what you got", cached_votes_up: 1,   tag_list: "Sport")
      proposal3 = create(:proposal, title: "Do not display with same tag", cached_votes_up: 100, tag_list: "Sport")
      proposal4 = create(:proposal, title: "Do not display",    cached_votes_up: 1)
      proposal5 = create(:proposal, tag_list: "Sport")
      create(:follow, followable: proposal5, user: user)

      visit proposals_path
      fill_in "search", with: "Show you got"
      click_button "Search"
      click_link 'recommendations'
      expect(page).to have_selector("a.active", text: "recommendations")

      within("#proposals") do
        expect(all(".proposal")[0].text).to match "Show you got"
        expect(all(".proposal")[1].text).to match "Show what you got"
        expect(page).to_not have_content "Do not display with same tag"
        expect(page).to_not have_content "Do not display"
      end
      Setting['feature.user.recommendations'] = nil
    end

    scenario 'After a search do not show featured proposals' do
      featured_proposals = create_featured_proposals
      proposal = create(:proposal, title: "Abcdefghi")

      visit proposals_path
      within(".expanded #search_form") do
        fill_in "search", with: proposal.title
        click_button "Search"
      end

      expect(page).to_not have_selector('#proposals .proposal-featured')
      expect(page).to_not have_selector('#featured-proposals')
    end

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

  scenario 'Flagging/Unflagging AJAX', :js do
    user = create(:user)
    proposal = create(:proposal)

    login_as(user)
    visit proposal_path(proposal)

    # Flagging
    within "#proposal_#{proposal.id}" do
      page.find("#flag-expand-proposal-#{proposal.id}").click
      page.find("#flag-proposal-#{proposal.id}").click

      expect(page).to have_css("#unflag-expand-proposal-#{proposal.id}")
    end

    expect(Flag.flagged?(user, proposal)).to be

    # Unflagging
    within "#proposal_#{proposal.id}" do
      page.find("#unflag-expand-proposal-#{proposal.id}").click
      page.find("#unflag-proposal-#{proposal.id}").click

      expect(page).to have_css("#flag-expand-proposal-#{proposal.id}")
    end

    expect(Flag.flagged?(user, proposal)).to_not be
  end

  it_behaves_like "followable", "proposal", "proposal_path", { "id": "id" }

  it_behaves_like "imageable", "proposal", "proposal_path", { "id": "id" }

  it_behaves_like "nested imageable",
                  "proposal",
                  "new_proposal_path",
                  { },
                  "imageable_fill_new_valid_proposal",
                  "Create proposal",
                  "Proposal created successfully"

  it_behaves_like "nested imageable",
                  "proposal",
                  "edit_proposal_path",
                  { "id": "id" },
                  nil,
                  "Save changes",
                  "Proposal updated successfully"

  it_behaves_like "documentable", "proposal", "proposal_path", { "id": "id" }

  it_behaves_like "nested documentable",
                  "user",
                  "proposal",
                  "new_proposal_path",
                  { },
                  "documentable_fill_new_valid_proposal",
                  "Create proposal",
                  "Proposal created successfully"

  it_behaves_like "nested documentable",
                  "user",
                  "proposal",
                  "edit_proposal_path",
                  { "id": "id" },
                  nil,
                  "Save changes",
                  "Proposal updated successfully"

  it_behaves_like "mappable",
                  "proposal",
                  "proposal",
                  "new_proposal_path",
                  "edit_proposal_path",
                  "proposal_path",
                  { }

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

  context "Filter" do

    context "By geozone" do

      background do
        @california = Geozone.create(name: "California")
        @new_york   = Geozone.create(name: "New York")

        @proposal1 = create(:proposal, geozone: @california)
        @proposal2 = create(:proposal, geozone: @california)
        @proposal3 = create(:proposal, geozone: @new_york)
      end

      scenario "From map" do
        visit proposals_path

        click_link "map"
        within("#html_map") do
          url = find("area[title='California']")[:href]
          visit url
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 2)
          expect(page).to have_content(@proposal1.title)
          expect(page).to have_content(@proposal2.title)
          expect(page).to_not have_content(@proposal3.title)
        end
      end

      scenario "From geozone list" do
        visit proposals_path

        click_link "map"
        within("#geozones") do
          click_link "California"
        end
        within("#proposals") do
          expect(page).to have_css('.proposal', count: 2)
          expect(page).to have_content(@proposal1.title)
          expect(page).to have_content(@proposal2.title)
          expect(page).to_not have_content(@proposal3.title)
        end
      end

      scenario "From proposal" do
        visit proposal_path(@proposal1)

        within("#geozone") do
          click_link "California"
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 2)
          expect(page).to have_content(@proposal1.title)
          expect(page).to have_content(@proposal2.title)
          expect(page).to_not have_content(@proposal3.title)
        end
      end

    end
  end

  context 'Suggesting proposals' do
    scenario 'Show up to 5 suggestions', :js do
      author = create(:user)
      login_as(author)

      create(:proposal, title: 'First proposal, has search term')
      create(:proposal, title: 'Second title')
      create(:proposal, title: 'Third proposal, has search term')
      create(:proposal, title: 'Fourth proposal, has search term')
      create(:proposal, title: 'Fifth proposal, has search term')
      create(:proposal, title: 'Sixth proposal, has search term')
      create(:proposal, title: 'Seventh proposal, has search term')

      visit new_proposal_path
      fill_in 'proposal_title', with: 'search'
      check "proposal_terms_of_service"

      within('div#js-suggest') do
        expect(page).to have_content "You are seeing 5 of 6 proposals containing the term 'search'"
      end
    end

    scenario 'No found suggestions', :js do
      author = create(:user)
      login_as(author)

      create(:proposal, title: 'First proposal').update_column(:confidence_score, 10)
      create(:proposal, title: 'Second proposal').update_column(:confidence_score, 8)

      visit new_proposal_path
      fill_in 'proposal_title', with: 'debate'
      check "proposal_terms_of_service"

      within('div#js-suggest') do
        expect(page).to_not have_content 'You are seeing'
      end
    end
  end

  context "Summary" do

    scenario "Displays proposals grouped by category" do
      create(:tag, :category, name: 'Culture')
      create(:tag, :category, name: 'Social Services')

      3.times { create(:proposal, tag_list: 'Culture') }
      3.times { create(:proposal, tag_list: 'Social Services') }

      create(:proposal, tag_list: 'Random')

      visit proposals_path
      click_link "The most supported proposals by category"

      within("#culture") do
        expect(page).to have_content("Culture")
        expect(page).to have_css(".proposal", count: 3)
      end

      within("#social-services") do
        expect(page).to have_content("Social Services")
        expect(page).to have_css(".proposal", count: 3)
      end
    end

    scenario "Displays proposals grouped by district" do
      california = create(:geozone, name: 'California')
      new_york   = create(:geozone, name: 'New York')

      3.times { create(:proposal, geozone: california) }
      3.times { create(:proposal, geozone: new_york) }

      visit proposals_path
      click_link "The most supported proposals by category"

      within("#california") do
        expect(page).to have_content("California")
        expect(page).to have_css(".proposal", count: 3)
      end

      within("#new-york") do
        expect(page).to have_content("New York")
        expect(page).to have_css(".proposal", count: 3)
      end
    end

    scenario "Displays a maximum of 3 proposals per category" do
      create(:tag, :category, name: 'culture')
      4.times { create(:proposal, tag_list: 'culture') }

      visit summary_proposals_path

      expect(page).to have_css(".proposal", count: 3)
    end

    scenario "Orders proposals by votes" do
      create(:tag, :category, name: 'culture')
      create(:proposal, title: 'Best',   tag_list: 'culture').update_column(:confidence_score, 10)
      create(:proposal, title: 'Worst',  tag_list: 'culture').update_column(:confidence_score, 2)
      create(:proposal, title: 'Medium', tag_list: 'culture').update_column(:confidence_score, 5)

      visit summary_proposals_path

      expect('Best').to appear_before('Medium')
      expect('Medium').to appear_before('Worst')
    end

    scenario "Displays proposals from last week" do
      create(:tag, :category, name: 'culture')
      proposal1 = create(:proposal, tag_list: 'culture', created_at: 1.day.ago)
      proposal2 = create(:proposal, tag_list: 'culture', created_at: 5.days.ago)
      proposal3 = create(:proposal, tag_list: 'culture', created_at: 8.days.ago)

      visit summary_proposals_path

      within("#proposals") do
        expect(page).to have_css('.proposal', count: 2)

        expect(page).to have_content(proposal1.title)
        expect(page).to have_content(proposal2.title)
        expect(page).to_not have_content(proposal3.title)
      end
    end

  end

end

feature 'Successful proposals' do

  scenario 'Successful proposals do not show support buttons in index' do
    successful_proposals = create_successful_proposals

    visit proposals_path

    successful_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to_not have_css(".supports")
        expect(page).to have_content "This proposal has reached the required supports"
      end
    end
  end

  scenario 'Successful proposals do not show support buttons in show' do
    successful_proposals = create_successful_proposals

    successful_proposals.each do |proposal|
      visit proposal_path(proposal)
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to_not have_css(".supports")
        expect(page).to have_content "This proposal has reached the required supports"
      end
    end
  end

  scenario 'Successful proposals show create question button to admin users' do
    successful_proposals = create_successful_proposals

    visit proposals_path

    successful_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to_not have_link "Create question"
      end
    end

    login_as(create(:administrator).user)

    visit proposals_path

    successful_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to have_link "Create question"
      end
    end

  end
end
