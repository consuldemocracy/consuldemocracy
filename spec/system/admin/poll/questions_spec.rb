require "rails_helper"

describe "Admin poll questions", :admin do
  let(:future_poll) { create(:poll, name: "Movies") }
  let(:current_poll) { create(:poll, :current, name: "Movies") }

  scenario "Index" do
    poll1 = create(:poll)
    poll2 = create(:poll)
    poll3 = create(:poll)
    proposal = create(:proposal)
    question1 = create(:poll_question, poll: poll1)
    question2 = create(:poll_question, poll: poll2)
    question3 = create(:poll_question, poll: poll3, proposal: proposal)

    visit admin_poll_path(poll1)
    expect(page).to have_content(poll1.name)

    within("#poll_question_#{question1.id}") do
      expect(page).to have_content(question1.title)
      expect(page).to have_link "Edit answers"
      expect(page).to have_link "Edit"
      expect(page).to have_button "Delete"
    end

    visit admin_poll_path(poll2)
    expect(page).to have_content(poll2.name)

    within("#poll_question_#{question2.id}") do
      expect(page).to have_content question2.title
      expect(page).to have_link "Edit answers"
      expect(page).to have_link "Edit"
      expect(page).to have_button "Delete"
    end

    visit admin_poll_path(poll3)
    expect(page).to have_content(poll3.name)

    within("#poll_question_#{question3.id}") do
      expect(page).to have_content question3.title
      expect(page).to have_link "(See proposal)", href: proposal_path(question3.proposal)
      expect(page).to have_link "Edit answers"
      expect(page).to have_link "Edit"
      expect(page).to have_button "Delete"
    end
  end

  scenario "Show" do
    geozone = create(:geozone)
    poll = create(:poll, geozone_restricted: true, geozone_ids: [geozone.id])
    question = create(:poll_question, poll: poll)

    visit admin_poll_path(poll)

    within(".callout.warning") do
      expect(page).to have_content "Once poll has started it will not be possible to create, edit or "\
                                   "delete questions, answers or any content associated with the poll."
    end

    click_link "Edit answers"

    expect(page).to have_content(question.title)
    expect(page).to have_content(question.author.name)
  end

  context "Create" do
    scenario "Is possible for a not started poll" do
      visit admin_poll_path(future_poll)
      click_link "Create question"

      expect(page).to have_content("Create question to poll Movies")
      expect(page).to have_selector("input[id='poll_question_poll_id'][value='#{future_poll.id}']",
                                    visible: :hidden)
      fill_in "Question", with: "Star Wars: Episode IV - A New Hope"

      click_button "Save"
      expect(page).to have_content "Star Wars: Episode IV - A New Hope"
      expect(future_poll.questions).not_to be_empty
    end

    scenario "Is not possible for an already started poll" do
      visit admin_poll_path(current_poll)
      click_link "Create question"

      expect(page).to have_content("Create question to poll Movies")
      expect(page).to have_selector("input[id='poll_question_poll_id'][value='#{current_poll.id}']",
                                    visible: :hidden)
      fill_in "Question", with: "Star Wars: Episode IV - A New Hope"

      click_button "Save"
      expect(page).not_to have_content "Star Wars: Episode IV - A New Hope"
      expect(page).to have_content "It is not possible to create questions for an already started poll."
      expect(future_poll.questions).to be_empty
    end
  end

  scenario "Create from proposal" do
    create(:poll, name: "Proposals")
    proposal = create(:proposal)

    visit admin_proposal_path(proposal)

    expect(page).not_to have_content("This proposal has reached the required supports")
    click_link "Add this proposal to a poll to be voted"

    expect(page).to have_current_path(new_admin_question_path, ignore_query: true)
    expect(page).to have_field("Question", with: proposal.title)

    select "Proposals", from: "poll_question_poll_id"

    click_button "Save"

    expect(page).to have_content(proposal.title)
  end

  scenario "Create from successful proposal" do
    create(:poll, name: "Proposals")
    proposal = create(:proposal, :successful)

    visit admin_proposal_path(proposal)

    expect(page).to have_content("This proposal has reached the required supports")
    click_link "Add this proposal to a poll to be voted"

    expect(page).to have_current_path(new_admin_question_path, ignore_query: true)
    expect(page).to have_field("Question", with: proposal.title)

    select "Proposals", from: "poll_question_poll_id"

    click_button "Save"

    expect(page).to have_content(proposal.title)

    visit admin_questions_path

    expect(page).to have_content(proposal.title)
  end

  context "Update" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      old_title = question.title
      new_title = "Vegetables are great and everyone should have one"

      visit admin_poll_path(future_poll)

      within("#poll_question_#{question.id}") do
        click_link "Edit"
      end

      fill_in "Question", with: new_title

      click_button "Save"

      expect(page).to have_content "Changes saved"
      question.reload
      expect(question.title).to eq new_title
      expect(question.title).not_to eq old_title
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      old_title = question.title
      new_title = "Vegetables are great and everyone should have one"

      visit admin_poll_path(current_poll)

      within("#poll_question_#{question.id}") do
        click_link "Edit"
      end

      expect(page).to have_content "It is not possible to modify questions for an already started poll."
      question.reload
      expect(question.title).not_to eq new_title
      expect(question.title).to eq old_title
    end
  end

  context "Destroy" do
    scenario "Is possible for a not started poll" do
      question1 = create(:poll_question, poll: future_poll)
      question2 = create(:poll_question, poll: future_poll)

      visit admin_poll_path(future_poll)

      within("#poll_question_#{question1.id}") do
        accept_confirm("Are you sure? This action will delete \"#{question1.title}\" and can't be undone.") do
          click_button "Delete"
        end
      end

      expect(page).not_to have_content(question1.title)
      expect(page).to have_content(question2.title)
      expect(future_poll.questions.count).to be 1
    end

    scenario "Is not possible for an already started poll" do
      create_list(:poll_question, 2, poll: current_poll)

      visit admin_poll_path(current_poll)

      within("#poll_question_#{current_poll.questions.first.id}") do
        accept_confirm { click_button "Delete" }
      end

      expect(page).to have_content "It is not possible to delete questions for an already started poll."
      expect(current_poll.questions.count).to be 2
    end
  end

  context "Poll select box" do
    scenario "translates the poll name in options" do
      poll = create(:poll, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select "Español", from: "Language:"

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Seleccionar votación", poll.name_es])
    end

    scenario "uses fallback if name is not translated to current locale",
             if: Globalize.fallbacks(:fr).reject { |locale| locale.match(/fr/) }.first == :es do
      poll = create(:poll, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select "Français", from: "Language:"

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Sélectionner un vote", poll.name_es])
    end
  end
end
