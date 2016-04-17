require 'rails_helper'

feature 'Open Plenary' do

  let!(:debate) { create(:debate, comment_kind: 'question', tag_list: "plenoabierto") }

  scenario "Create a question", :js do
    author = create(:user)
    login_as(author)

    visit root_path
    first(:link, "Open processes").click
    click_link "Send a proposal or question"
    click_link "Make a question"

    fill_in "comment-body-debate_#{debate.id}", with: 'Is there a way to...?'
    click_button 'Publish question'

    within "#comments" do
      expect(page).to have_content 'Is there a way to...?'
      expect(page).to have_content 'Questions (1)'
    end
  end

  scenario "Create a proposal" do
    author = create(:user)
    login_as(author)

    visit root_path
    first(:link, "Open processes").click
    click_link "Send a proposal or question"
    click_link "Send a proposal"

    fill_in_proposal
    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    within("#tags") do
      expect(page).to have_content "plenoabierto"
    end
  end

  scenario "Question's index" do
    author = create(:user)
    question1 = create(:comment, commentable: debate)
    question2 = create(:comment, commentable: debate)

    login_as(author)
    visit "processes_open_plenary"

    click_link "See all questions"

    within("#comments") do
      expect(page).to have_content "Questions (2)"
      expect(page).to have_content question1.body
      expect(page).to have_content question2.body
    end
  end

  scenario "Proposal's index" do
    proposal1 = create(:proposal, title: "Plant more trees",  tag_list: 'plenoabierto')
    proposal2 = create(:proposal, title: "Feed the children", tag_list: 'plenoabierto')
    proposal3 = create(:proposal, title: "Take care of the rich")

    visit "processes_open_plenary"

    click_link "See all proposals"

    within("#proposals") do
      expect(page).to have_css('.proposal', count: 2)

      expect(page).to have_content(proposal1.title)
      expect(page).to have_content(proposal2.title)
      expect(page).to_not have_content(proposal3.title)
    end
  end

end