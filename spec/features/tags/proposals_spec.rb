require 'rails_helper'

feature 'Tags' do

  scenario 'Index' do
    create_featured_proposals
    earth = create(:proposal, tag_list: 'Medio Ambiente')
    money = create(:proposal, tag_list: 'Economía')

    visit proposals_path

    within "#proposal_#{earth.id}" do
      expect(page).to have_content "Medio Ambiente"
    end

    within "#proposal_#{money.id}" do
      expect(page).to have_content "Economía"
    end
  end

  scenario 'Index shows up to 5 tags per proposal' do
    create_featured_proposals
    tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
    create :proposal, tag_list: tag_list

    visit proposals_path

    within('.proposal .tags') do
      expect(page).to have_content '1+'
    end
  end

  scenario 'Index featured proposals does not show tags' do
    featured_proposals = create_featured_proposals
    proposal = create(:proposal, tag_list: "123")

    visit proposals_path(tag: "123")

    expect(page).to_not have_selector('#proposals .proposal-featured')
    expect(page).to_not have_selector('#featured-proposals')
  end

  scenario 'Index shows 3 tags with no plus link' do
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

  scenario 'Show' do
    proposal = create(:proposal, tag_list: 'Hacienda, Economía')

    visit proposal_path(proposal)

    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
  end

  scenario 'Create with custom tags' do
    user = create(:user)
    login_as(user)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_tag_list', with: 'Economía, Hacienda'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'Economía'
    expect(page).to have_content 'Hacienda'
  end

  scenario 'Category with category tags', :js do
    user = create(:user)
    login_as(user)

    education = create(:tag, :category, name: 'Education')
    health    = create(:tag, :category, name: 'Health')

    visit new_proposal_path

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in_ckeditor 'proposal_description', with: 'A description with enough characters'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=Ae6gQmhaMn4'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    find('.js-add-tag-link', text: 'Education').click
    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    within "#tags_proposal_#{Proposal.last.id}" do
      expect(page).to have_content 'Education'
      expect(page).to_not have_content 'Health'
    end
  end

  scenario 'Create with too many tags' do
    user = create(:user)
    login_as(user)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Title'
    fill_in 'proposal_description', with: 'Description'
    check 'proposal_terms_of_service'

    fill_in 'proposal_tag_list', with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button 'Create proposal'

    expect(page).to have_content error_message
    expect(page).to have_content 'tags must be less than or equal to 6'
  end

  scenario 'Create with dangerous strings' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in 'proposal_title', with: 'A test of dangerous strings'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'A description suitable for this test'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    fill_in 'proposal_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'

    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'user_id1'
    expect(page).to have_content 'a3'
    expect(page).to have_content 'scriptalert("hey");script'
    expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
  end

  scenario 'Update' do
    proposal = create(:proposal, tag_list: 'Economía')

    login_as(proposal.author)
    visit edit_proposal_path(proposal)

    expect(page).to have_selector("input[value='Economía']")

    fill_in 'proposal_tag_list', with: "Economía, Hacienda"
    click_button 'Save changes'

    expect(page).to have_content 'Proposal updated successfully.'
    within('.tags') do
      expect(page).to have_css('a', text: 'Economía')
      expect(page).to have_css('a', text: 'Hacienda')
    end
  end

  scenario 'Delete' do
    proposal = create(:proposal, tag_list: 'Economía')

    login_as(proposal.author)
    visit edit_proposal_path(proposal)

    fill_in 'proposal_tag_list', with: ""
    click_button 'Save changes'

    expect(page).to have_content 'Proposal updated successfully.'
    expect(page).to_not have_content 'Economía'
  end

  context "Filter" do

    scenario "From index" do
      create_featured_proposals
      proposal1 = create(:proposal, tag_list: 'Education')
      proposal2 = create(:proposal, tag_list: 'Health')

      visit proposals_path

      within "#proposal_#{proposal1.id}" do
        click_link "Education"
      end

      within("#proposals") do
        expect(page).to have_css('.proposal', count: 1)
        expect(page).to have_content(proposal1.title)
      end
    end

    scenario "From show" do
      proposal1 = create(:proposal, tag_list: 'Education')
      proposal2 = create(:proposal, tag_list: 'Health')

      visit proposal_path(proposal1)

      click_link "Education"

      within("#proposals") do
        expect(page).to have_css('.proposal', count: 1)
        expect(page).to have_content(proposal1.title)
      end
    end

  end

  context 'Tag cloud' do

    scenario 'Display user tags' do
      earth = create(:proposal, tag_list: 'Medio Ambiente')
      money = create(:proposal, tag_list: 'Economía')

      visit proposals_path

      within "#tag-cloud" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "Filter by user tags" do
      proposal1 = create(:proposal, tag_list: 'Medio Ambiente')
      proposal2 = create(:proposal, tag_list: 'Medio Ambiente')
      proposal3 = create(:proposal, tag_list: 'Economía')

      visit proposals_path

      within "#tag-cloud" do
        click_link "Medio Ambiente"
      end

      expect(page).to have_css ".proposal", count: 2
      expect(page).to have_content proposal1.title
      expect(page).to have_content proposal2.title
      expect(page).to_not have_content proposal3.title
    end

  end

  context "Categories" do

    scenario 'Display category tags' do
      create(:tag, :category, name: 'Medio Ambiente')
      create(:tag, :category, name: 'Economía')

      earth = create(:proposal, tag_list: 'Medio Ambiente')
      money = create(:proposal, tag_list: 'Economía')

      visit proposals_path

      within "#categories" do
        expect(page).to have_content "Medio Ambiente"
        expect(page).to have_content "Economía"
      end
    end

    scenario "Filter by category tags" do
      create(:tag, :category, name: 'Medio Ambiente')
      create(:tag, :category, name: 'Economía')

      proposal1 = create(:proposal, tag_list: 'Medio Ambiente')
      proposal2 = create(:proposal, tag_list: 'Medio Ambiente')
      proposal3 = create(:proposal, tag_list: 'Economía')

      visit proposals_path

      within "#categories" do
        click_link "Medio Ambiente"
      end

      expect(page).to have_css ".proposal", count: 2
      expect(page).to have_content proposal1.title
      expect(page).to have_content proposal2.title
      expect(page).to_not have_content proposal3.title
    end
  end
end
