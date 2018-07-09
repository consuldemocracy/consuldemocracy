require 'rails_helper'

feature 'Masdemocraciaeuropa proposals' do

  background do
    Setting["org_name"] = 'MASDEMOCRACIAEUROPA'
    Setting["feature.user.skip_verification"] = "true"
  end

  before do
    author = create(:user)
    login_as(author)
  end

  describe "New" do
    let!(:proposal) { create(:proposal) }

    scenario "Should not display proposal geozone form select" do
      visit new_proposal_path

      expect(page).not_to have_selector "select#proposal_geozone_id"
    end

    scenario "Should not display proposal summary form field" do
      visit new_proposal_path

      expect(page).not_to have_selector "textarea#proposal_summary"
    end

    scenario "Should not display proposal question form field" do
      visit new_proposal_path

      expect(page).not_to have_selector "textarea#question"
    end

    scenario "Should display custom submit button" do
      visit new_proposal_path

      expect(page.find("input[type='submit']").value).to eq 'Send your proposal'
    end
  end

  describe "Index" do

    scenario "Should not display district map" do
      visit proposals_path

      expect(page).not_to have_selector "a#map"
    end

    scenario "Should not display proposal summary field" do
      proposal = create(:proposal, summary: "Summary", objective: "Objective <br> sample")
      visit proposals_path

      expect(page).not_to have_content "Summary"
    end

    scenario "Should display stripped objective attribute contents" do
      proposal = create(:proposal, summary: nil, objective: "Objective <br> sample")
      visit proposals_path

      expect(page).to have_content "Objective sample"
    end

    scenario "Should not display geozone information" do
      visit proposals_path

      expect(page).not_to have_selector "#geozone"
    end

    scenario "Dont display popular section on sidebar when org_name is MASDEMOCRACIAEUROPA" do
      proposal = create(:proposal)

      visit proposals_path

      expect(page).not_to have_content I18n.t("proposals.index.top_link_proposals")
      expect(page).not_to have_content I18n.t("proposals.index.top")
    end

    scenario "Dont display votes section on proposal partial when org_name is MASDEMOCRACIAEUROPA" do
      proposal = create(:proposal)

      visit proposals_path

      expect(page).not_to have_css "#proposal_#{proposal.id}_votes"
    end

    scenario "Dont display featured proposals partial when org_name is MASDEMOCRACIAEUROPA" do
      proposal = create(:proposal)

      visit proposals_path

      expect(page).not_to have_css "#featured-proposals"
    end

    scenario "Dont display highest_rated order when org_name is MASDEMOCRACIAEUROPA" do
      proposal = create(:proposal)

      visit proposals_path

      expect(page).not_to have_content "highest rated"
    end

  end

  describe "Show" do

    scenario "Dont display votes section on proposal partial when org_name is MASDEMOCRACIAEUROPA" do
      proposal = create(:proposal)

      visit proposal_path(proposal)

      expect(page).not_to have_css "#proposal_#{proposal.id}_votes"
      expect(page).not_to have_content I18n.t("votes.supports")
    end

    scenario "Dont display summary" do
      proposal = create(:proposal, summary: "Summary")

      visit proposal_path(proposal)

      expect(page).not_to have_content "Summary"
    end

    scenario "Dont display question" do
      proposal = create(:proposal, question: "A very good question?")

      visit proposal_path(proposal)

      expect(page).not_to have_content "A very good question?"
    end

    scenario "Should display objective" do
      proposal = create(:proposal, objective: "A very good objective")

      visit proposal_path(proposal)

      expect(page).to have_content "A very good objective"
    end

    scenario "Should display impact_description" do
      proposal = create(:proposal, impact_description: "A very good impact description")

      visit proposal_path(proposal)

      expect(page).to have_content "A very good impact description"
    end

    scenario "Should display feasible_explanation" do
      proposal = create(:proposal, feasible_explanation: "A very good feasible explanation")

      visit proposal_path(proposal)

      expect(page).to have_content "A very good feasible explanation"
    end

  end

  describe "Create" do
    scenario "Should show successful notice" do
      author = create(:user)
      login_as(author)
      visit new_proposal_path

      fill_in 'proposal_title', with: 'Help refugees'
      fill_in 'proposal_objective', with: 'To minimize refugees at Europe'
      fill_in 'proposal_impact_description', with: 'This should affect to ..'
      fill_in 'proposal_feasible_explanation', with: 'This could be done if all of we ...'
      fill_in 'proposal_description', with: 'This is very important because...'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=yPQfcG-eimk'
      fill_in 'proposal_tag_list', with: 'Refugees, Solidarity'
      check 'proposal_terms_of_service'

      click_button 'Send your proposal'

      expect(page).to have_content 'Proposal created successfully.'
    end
  end

  describe "Update" do
    let!(:author) { create(:user) }

    scenario 'Should show success' do
      author = create(:user)
      proposal = create(:proposal, author: author)
      login_as(proposal.author)

      visit edit_proposal_path(proposal)
      expect(page).to have_current_path(edit_proposal_path(proposal))

      fill_in 'proposal_title', with: "End child poverty"
      fill_in 'proposal_objective', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_objective', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_objective', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_description', with: "Let's do something to end child poverty"
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'

      click_button "Save changes"

      expect(page).to have_content "Proposal updated successfully."
    end
  end
end
