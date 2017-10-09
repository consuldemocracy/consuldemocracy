require 'rails_helper'

feature 'Admin poll questions' do

  background do
    login_as(create(:administrator).user)
  end

  scenario 'Index' do
    question1 = create(:poll_question)
    question2 = create(:poll_question)

    visit admin_questions_path

    expect(page).to have_content(question1.title)
    expect(page).to have_content(question2.title)
  end

  scenario 'Show' do
    geozone = create(:geozone)
    poll = create(:poll, geozone_restricted: true, geozone_ids: [geozone.id])
    question = create(:poll_question, poll: poll)

    visit admin_question_path(question)

    expect(page).to have_content(question.title)
    expect(page).to have_content(question.author.name)
  end

  scenario 'Create' do
    poll = create(:poll, name: 'Movies')
    title = "Star Wars: Episode IV - A New Hope"
    description = %{
      During the battle, Rebel spies managed to steal secret plans to the Empire's ultimate weapon, the DEATH STAR, an armored space station
       with enough power to destroy an entire planet.
      Pursued by the Empire's sinister agents, Princess Leia races home aboard her starship, custodian of the stolen plans that can save her
       people and restore freedom to the galaxy....
    }
    video_url = "https://puppyvideos.com"

    visit admin_questions_path
    click_link "Create question"

    select 'Movies', from: 'poll_question_poll_id'
    fill_in 'poll_question_title', with: title
    fill_in 'poll_question_video_url', with: video_url

    click_button 'Save'

    expect(page).to have_content(title)
    expect(page).to have_content(video_url)
  end

  scenario 'Create from successful proposal index' do
    poll = create(:poll, name: 'Proposals')
    proposal = create(:proposal, :successful)

    visit proposals_path
    click_link "Create question"

    expect(current_path).to eq(new_admin_question_path)
    expect(page).to have_field('poll_question_title', with: proposal.title)

    select 'Proposals', from: 'poll_question_poll_id'

    click_button 'Save'

    expect(page).to have_content(proposal.title)
    expect(page).to have_link(proposal.title, href: proposal_path(proposal))
    expect(page).to have_link(proposal.author.name, href: user_path(proposal.author))
  end

  pending "Create from successul proposal show"

  scenario 'Update' do
    question1 = create(:poll_question)

    visit admin_questions_path
    within("#poll_question_#{question1.id}") do
      click_link "Edit"
    end

    old_title = question1.title
    new_title = "Potatoes are great and everyone should have one"
    fill_in 'poll_question_title', with: new_title

    click_button 'Save'

    expect(page).to have_content "Changes saved"
    expect(page).to have_content new_title

    visit admin_questions_path

    expect(page).to have_content(new_title)
    expect(page).to_not have_content(old_title)
  end

  scenario 'Destroy' do
    question1 = create(:poll_question)
    question2 = create(:poll_question)

    visit admin_questions_path

    within("#poll_question_#{question1.id}") do
      click_link "Delete"
    end

    expect(page).to_not have_content(question1.title)
    expect(page).to have_content(question2.title)
  end

  pending "Mark all city by default when creating a poll question from a successful proposal"

end
