require 'rails_helper'

feature 'Open Plenary' do

  let!(:debate) { create(:debate, comment_kind: 'question', tag_list: "plenoabierto") }

  scenario "Question's index" do
    author = create(:user)
    question1 = create(:comment, commentable: debate)
    question2 = create(:comment, commentable: debate)

    login_as(author)
    visit open_plenary_path

    click_link "See the most voted proposals and questions"
    click_link "See all questions"

    within("#comments") do
      expect(page).to have_content "Questions (2)"
      expect(page).to have_content question1.body
      expect(page).to have_content question2.body
    end
  end

  scenario "Hide supports (index)" do
    proposal = create(:proposal, title: "Plant more trees", tag_list: 'plenoabierto')

    visit proposals_path(search: 'plenoabierto')

    within("#proposals") do
      expect(page).to have_css('.proposal', count: 1)
      expect(page).to have_content(proposal.title)
      expect(page).to have_content('Pleno Abierto')

      expect(page).to_not have_content "0% / 100%"
      expect(page).to_not have_content('supports needed')
    end
  end

  scenario "Hide supports (show)" do
    proposal = create(:proposal, title: "Plant more trees", tag_list: 'plenoabierto')

    visit proposal_path(proposal)

    within("#proposal_#{proposal.id}") do
      expect(page).to have_content(proposal.title)
      expect(page).to have_content('Pleno Abierto')

      expect(page).to_not have_content "0% / 100%"
      expect(page).to_not have_content('supports needed')
    end
  end

end