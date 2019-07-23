require "rails_helper"

describe "Admin poll questions" do

  before do
    login_as(create(:administrator).user)
  end

  it_behaves_like "edit_translatable",
                  "poll_question",
                  "edit_admin_question_path",
                  %w[title]

  scenario "Index" do
    poll1 = create(:poll)
    poll2 = create(:poll)
    poll3 = create(:poll)
    proposal = create(:proposal)
    question1 = create(:poll_question, poll: poll1)
    question2 = create(:poll_question, poll: poll2)
    question3 = create(:poll_question, poll: poll3, proposal: proposal)
    question4 = create(:poll_question_unique, poll: poll1)

    visit admin_poll_path(poll1)
    expect(page).to have_content(poll1.name)

    within("#poll_question_#{question1.id}") do
      expect(page).to have_content(question1.title)
      expect(page).to have_content("Edit answers")
      expect(page).to have_content("Edit")
      expect(page).to have_content("Delete")
    end

    within("#poll_question_#{question4.id}") do
      expect(page).to have_content(question4.title)
      expect(page).to have_content("Edit answers")
      expect(page).to have_content("Edit")
      expect(page).to have_content("Delete")
    end

    visit admin_poll_path(poll2)
    expect(page).to have_content(poll2.name)

    within("#poll_question_#{question2.id}") do
      expect(page).to have_content(question2.title)
      expect(page).to have_content("Edit answers")
      expect(page).to have_content("Edit")
      expect(page).to have_content("Delete")
    end

    visit admin_poll_path(poll3)
    expect(page).to have_content(poll3.name)

    within("#poll_question_#{question3.id}") do
      expect(page).to have_content(question3.title)
      expect(page).to have_link("(See proposal)", href: proposal_path(question3.proposal))
      expect(page).to have_content("Edit answers")
      expect(page).to have_content("Edit")
      expect(page).to have_content("Delete")
    end
  end

  context "Show" do
    scenario "Without Votation type" do
      geozone = create(:geozone)
      poll = create(:poll, geozone_restricted: true, geozone_ids: [geozone.id])
      question = create(:poll_question, poll: poll)

      visit admin_poll_path(poll)
      click_link question.title

      expect(page).to have_content(question.title)
      expect(page).to have_content(question.author.name)
      expect(page).not_to have_content("Votation type")
    end

    scenario "With Votation type" do
      geozone = create(:geozone)
      poll = create(:poll, geozone_restricted: true, geozone_ids: [geozone.id])
      question = create(:poll_question_multiple, poll: poll)

      visit admin_poll_path(poll)
      click_link "#{question.title}"

      expect(page).to have_content(question.title)
      expect(page).to have_content(question.author.name)
      expect(page).to have_content("Votation type")
      expect(page).to have_content("Multiple")
      expect(page).to have_content("Maximum number of votes")
      expect(page).to have_content("5")
    end
  end

  scenario "Create" do
    poll = create(:poll, name: "Movies")
    title = "Star Wars: Episode IV - A New Hope"

    visit admin_poll_path(poll)
    click_link "Create question"

    expect(page).to have_content("Create question to poll Movies")
    expect(page).to have_selector("input[id='poll_question_poll_id'][value='#{poll.id}']",
                                   visible: false)
    fill_in "Question", with: title

    click_button "Save"

    expect(page).to have_content(title)
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

  context "create with votation type" do
    before do
      poll = create(:poll, name: "Movies")
      visit admin_poll_path(poll)
      click_link "Create question"
    end

    scenario "unique" do
      title = "unique question"
      fill_in "Question", with: title
      select "Unique answer, closed", from: "votation_type_enum_type"

      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Unique answer, closed")
    end

    scenario "multiple" do
      title = "multiple question"
      fill_in "Question", with: title
      select "Multiple answers, closed", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Multiple answers, closed")
    end

    scenario "prioritized" do
      title = "prioritized question"
      fill_in "Question", with: title
      select "Multiple prioritized answer, closed", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Multiple prioritized answer, closed")
    end

    scenario "positive_open" do
      title = "positive open question"
      fill_in "Question", with: title
      select "Votable positive, open", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Votable positive, open")
    end

    scenario "positive_negative_open" do
      title = "positive negative open question"
      fill_in "Question", with: title
      select "Votable positive and negative, open", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Votable positive and negative, open")
    end

    scenario "answer_couples_open" do
      title = "answer couples open question"
      fill_in "Question", with: title
      select "Couples of answers, open", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Couples of answers, open")
    end

    scenario "answer_couples_closed" do
      title = "answer couples closed question"
      fill_in "Question", with: title
      select "Couples of answers, closed", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Couples of answers, closed")
    end

    scenario "answer_set_open" do
      title = "answer set open question"
      fill_in "Question", with: title
      select "Set of answers, open", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of answers in the set", with: 3
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Set of answers, open")
    end

    scenario "answer_set_closed" do
      title = "answer set closed question"
      fill_in "Question", with: title
      select "Set of answers, closed", from: "votation_type_enum_type"

      expect(page).to have_content("Maximum number of votes")

      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of votes", with: 6
      click_button "Save"

      expect(page).to have_content("1 error prevented this Poll/Question from being saved.")

      fill_in "Maximum number of answers in the set", with: 3
      click_button "Save"

      expect(page).to have_content(title)
      expect(page).to have_content("Set of answers, closed")
    end
  end

  scenario "Update" do
    poll = create(:poll)
    question1 = create(:poll_question, poll: poll)

    visit admin_poll_path(poll)

    within("#poll_question_#{question1.id}") do
      click_link "Edit"
    end

    old_title = question1.title
    new_title = "Potatoes are great and everyone should have one"
    fill_in "Question", with: new_title

    click_button "Save"

    expect(page).to have_content "Changes saved"
    expect(page).to have_content new_title
    expect(page).not_to have_content(old_title)
  end

  scenario "Destroy" do
    poll = create(:poll)
    question1 = create(:poll_question, poll: poll)
    question2 = create(:poll_question, poll: poll)

    visit admin_poll_path(poll)

    within("#poll_question_#{question1.id}") do
      click_link "Delete"
    end

    expect(page).not_to have_content(question1.title)
    expect(page).to have_content(question2.title)
  end

  pending "Mark all city by default when creating a poll question from a successful proposal"

  context "Poll select box" do

    scenario "translates the poll name in options", :js do

      poll = create(:poll, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select("Español", from: "locale-switcher")

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Seleccionar votación", poll.name_es])
    end

    scenario "uses fallback if name is not translated to current locale", :js do
      unless globalize_french_fallbacks.first == :es
        skip("Spec only useful when French falls back to Spanish")
      end

      poll = create(:poll, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select("Français", from: "locale-switcher")

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Sélectionner un vote", poll.name_es])
    end
  end

  def globalize_french_fallbacks
    Globalize.fallbacks(:fr).reject { |locale| locale.match(/fr/) }
  end
end
