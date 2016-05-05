require 'rails_helper'

feature 'Open Plenary' do

  let!(:debate) { create(:debate, comment_kind: 'question', tag_list: "plenoabierto") }

  scenario "Create a question", :js do
    Timecop.freeze(DateTime.new(2016,4,21).beginning_of_day) do
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
  end

  scenario "Create a proposal" do
    Timecop.freeze(DateTime.new(2016,4,21).beginning_of_day) do
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
  end

  scenario "Question's index" do
    author = create(:user)
    question1 = create(:comment, commentable: debate)
    question2 = create(:comment, commentable: debate)

    login_as(author)
    visit "processes_open_plenary"

    click_link "See the most voted proposals and questions"
    click_link "See all questions"

    within("#comments") do
      expect(page).to have_content "Questions (2)"
      expect(page).to have_content question1.body
      expect(page).to have_content question2.body
    end
  end

  scenario "Proposal's index" do
    Timecop.freeze(DateTime.new(2016,4,21).beginning_of_day) do
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

  scenario "Supports (index)" do
    Timecop.freeze(DateTime.new(2016,4,21).beginning_of_day) do
      proposal = create(:proposal, title: "Plant more trees",  tag_list: 'plenoabierto')

      visit "processes_open_plenary"

      click_link "See all proposals"

      within("#proposals") do
        expect(page).to have_css('.proposal', count: 1)
        expect(page).to have_content(proposal.title)
        expect(page).to have_content('#PlenoAbierto')

        expect(page).to_not have_content "0% / 100%"
        expect(page).to_not have_content('supports needed')
      end
    end
  end

  scenario "Supports (show)" do
    proposal = create(:proposal, title: "Plant more trees",  tag_list: 'plenoabierto')

    visit proposal_path(proposal)

    within("#proposal_#{proposal.id}") do
      expect(page).to have_content(proposal.title)
      expect(page).to have_content('#PlenoAbierto')

      expect(page).to_not have_content "0% / 100%"
      expect(page).to_not have_content('supports needed')
    end
  end

  scenario "Hide advanced search", :js do
    Timecop.freeze(DateTime.new(2016,4,21).beginning_of_day) do
      create(:proposal, title: "Plant more trees",  tag_list: 'plenoabierto')

      visit "processes_open_plenary"
      click_link "See all proposals"

      within("#proposals") do
        expect(page).to have_css('.proposal', count: 1)
      end

      expect(page).to_not have_css("#js-advanced-search")
    end
  end

  scenario "Displays proposals created after official start date (April 18th)" do
    proposal1 = create(:proposal, title: "Before start date",  tag_list: 'plenoabierto', created_at: Date.parse('17-04-2016'))
    proposal2 = create(:proposal, title: "After start date",   tag_list: 'plenoabierto', created_at: Date.parse('18-04-2016'))

    visit "processes_open_plenary"
    click_link "See the most voted proposals and questions"
    click_link "See all proposals"

    within("#proposals") do
      expect(page).to have_content(proposal2.title)
      expect(page).to_not have_content(proposal1.title)
    end
  end

  context "Closed" do

    scenario "Display different text after official end time" do
      Timecop.freeze(DateTime.new(2016,4,21).beginning_of_day) do
        visit "processes_open_plenary"
        expect(page).to_not have_content("Apoya las propuestas y preguntas que más te gusten.")
      end

      Timecop.freeze(DateTime.new(2016,4,22).beginning_of_day) do
        visit "processes_open_plenary"
        expect(page).to have_content("Apoya las propuestas y preguntas que más te gusten.")
      end
    end

    scenario 'Displays proposals between the official dates' do
      proposal1 = create(:proposal, title: "Before start date",       tag_list: 'plenoabierto', created_at: Date.parse('17-04-2016'))
      proposal2 = create(:proposal, title: "During official dates",   tag_list: 'plenoabierto', created_at: Date.parse('18-04-2016'))
      proposal3 = create(:proposal, title: "During official dates",   tag_list: 'plenoabierto', created_at: Date.parse('19-04-2016'))
      proposal4 = create(:proposal, title: "After start date",        tag_list: 'plenoabierto', created_at: Date.parse('22-04-2016'))

      visit "processes_open_plenary"
      click_link "See the most voted proposals and questions"
      click_link "See all proposals"

      within("#proposals") do
        expect(page).to_not have_content(proposal1.title)
        expect(page).to have_content(proposal2.title)
        expect(page).to have_content(proposal3.title)
        expect(page).to_not have_content(proposal4.title)
      end
    end

  end

end