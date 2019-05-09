require "rails_helper"
require "sessions_helper"

feature "Legislation PeopleProposals" do

  let(:user)     { create(:user) }
  let(:user2)    { create(:user) }
  let(:admin)    { create(:administrator) }
  let(:process)  { create(:legislation_process) }
  let(:legislation_people_proposal) { create(:legislation_people_proposal) }
  let(:legislation_people_proposal_validated) { create(:legislation_people_proposal, :validated) }

  scenario "Only one menu element has 'active' CSS selector" do
    visit legislation_process_people_proposal_path(legislation_people_proposal_validated.process,
                                                   legislation_people_proposal_validated)

    within("#navigation_bar") do
      expect(page).to have_css(".is-active", count: 1)
    end
  end

  feature "Random pagination" do
    before do
      allow(Legislation::PeopleProposal).to receive(:default_per_page).and_return(12)

      create_list(
        :legislation_people_proposal,
        (Legislation::PeopleProposal.default_per_page + 2),
        process: process, validated: true
      )
    end

    xscenario "Each user has a different and consistent random proposals order", :js do
      in_browser(:one) do
        login_as user
        visit legislation_process_people_proposals_path(process)
        @first_user_people_proposals_order = legislation_people_proposals_order
      end

      in_browser(:two) do
        login_as user2
        visit legislation_process_people_proposals_path(process)
        @second_user_people_proposals_order = legislation_people_proposals_order
      end

      expect(@first_user_people_proposals_order).not_to eq(@second_user_people_proposals_order)

      in_browser(:one) do
        visit legislation_process_people_proposals_path(process)
        expect(legislation_people_proposals_order).to eq(@first_user_people_proposals_order)
      end

      in_browser(:two) do
        visit legislation_process_people_proposals_path(process)
        expect(legislation_people_proposals_order).to eq(@second_user_people_proposals_order)
      end
    end

    scenario "Random order maintained with pagination", :js do
      login_as user
      visit legislation_process_people_proposals_path(process)
      first_page_people_proposals_order = legislation_people_proposals_order

      click_link "Next"

      expect(page).to have_content "You're on page 2"
      expect(first_page_people_proposals_order & legislation_people_proposals_order).to eq([])

      click_link "Previous"

      expect(page).to have_content "You're on page 1"
      expect(legislation_people_proposals_order).to eq(first_page_people_proposals_order)
    end

    scenario "Does not crash when the seed is not a number" do
      login_as user
      visit legislation_process_people_proposals_path(process, random_seed: "Spoof")

      expect(page).to have_content "You're on page 1"
    end
  end

  context "Selected filter" do
    scenario "apperars even if there are not any selected poposals" do
      create(:legislation_people_proposal, legislation_process_id: process.id)

      visit legislation_process_people_proposals_path(process)

      expect(page).to have_content("Selected")
    end

    scenario "defaults to winners if there are selected proposals" do
      create(:legislation_people_proposal, :validated, legislation_process_id: process.id)
      create(:legislation_people_proposal,
        :validated,
        legislation_process_id: process.id,
        selected: true)

      visit legislation_process_people_proposals_path(process)

      expect(page).to have_link("Random")
      expect(page).not_to have_link("Selected")
      expect(page).to have_content("Selected")
    end

    scenario "defaults to random if the current process does not have selected proposals" do
      create(:legislation_people_proposal, :validated, legislation_process_id: process.id)
      create(:legislation_people_proposal, :validated, selected: true)

      visit legislation_process_people_proposals_path(process)

      expect(page).to have_link("Selected")
      expect(page).not_to have_link("Random")
      expect(page).to have_content("Random")
    end

    scenario "filters correctly" do
      proposal1 = create(:legislation_people_proposal,
        :validated,
        legislation_process_id: process.id)
      proposal2 = create(:legislation_people_proposal,
        :validated,
        legislation_process_id: process.id,
        selected: true)

      visit legislation_process_people_proposals_path(process, filter: "random")
      click_link "Selected"

      expect(page).to have_css("div#legislation_people_proposal_#{proposal2.id}")
      expect(page).not_to have_css("div#legislation_people_proposal_#{proposal1.id}")
    end
  end

  def legislation_people_proposals_order
    all("[id^='legislation_people_proposal_']").collect { |e| e[:id] }
  end

  context "Create a legislation people proposal" do
    scenario "Check validations for legislation people proposal", :js do
      login_as user
      visit new_legislation_process_people_proposal_path(process)

      click_button "Create proposal"

      expect(page).to have_content("4 errors prevented")
      expect(page).to have_content("can't be blank, is too short (minimum is 4 characters)")
      expect(page).to have_content("must be accepted")

      fill_in "Name", with: "Jon"
      click_button "Create proposal"

      expect(page).to have_content("3 errors prevented")
      expect(page).to have_content("is too short (minimum is 4 characters)")
      expect(page).to have_content("can't be blank")
      expect(page).to have_content("must be accepted")

      fill_in "Name", with: "Jon Snow"
      click_button "Create proposal"

      expect(page).to have_content("2 errors prevented")
      expect(page).to have_content("can't be blank")
      expect(page).to have_content("must be accepted")

      fill_in "Proposal summary", with: "Proposal summary"
      click_button "Create proposal"

      expect(page).to have_content("1 error prevented")
      expect(page).to have_content("must be accepted")

      check "legislation_people_proposal_terms_of_service"
      click_button "Create proposal"

      expect(page).to have_current_path(legislation_process_people_proposals_path(process))
      expect(page).to have_content("Thanks!, your proposal was created successfully.")
      expect(page).to have_content("An admin will validate it before be published")
    end

    scenario "Legislation people proposal will be visible only after admin validation", :js do
      login_as user
      visit new_legislation_process_people_proposal_path(process)

      fill_in "Name", with: "Jon Snow"
      fill_in "Proposal summary", with: "Proposal summary"
      check "legislation_people_proposal_terms_of_service"
      click_button "Create proposal"

      expect(page).to have_current_path(legislation_process_people_proposals_path(process))

      expect(page).not_to have_content("Jon Snow")
      expect(page).to have_content("There are no proposals")

      login_as(admin.user)

      visit admin_legislation_process_people_proposals_path(process)
      click_link "Validate"

      visit legislation_process_people_proposals_path(process)

      expect(page).to have_content("Jon Snow")
      expect(page).to have_content("Proposal summary")
    end

    scenario "Create a legislation people proposal with an image", :js do
      login_as user

      visit new_legislation_process_people_proposal_path(process)

      fill_in "Name", with: "Legislation proposal with image"
      fill_in "Proposal summary", with: "Including an image on a legislation proposal"
      imageable_attach_new_file(create(:image), Rails.root.join("spec/fixtures/files/clippy.jpg"))
      check "legislation_people_proposal_terms_of_service"
      click_button "Create proposal"

      expect(page).not_to have_content "Legislation proposal with image"
      expect(page).not_to have_content "Including an image on a legislation proposal"
      expect(page).not_to have_css("img[alt='#{Legislation::PeopleProposal.last.image.title}']")
    end

    scenario "Create a complete legislation people proposal", :js do
      login_as user

      visit new_legislation_process_people_proposal_path(process)

      fill_in "Name", with: "Jon Snow"
      fill_in "Phone", with: "666666666"
      fill_in "Email", with: "test@test.com"
      fill_in "Twitter", with: "@twitter"
      fill_in "Facebook", with: "@facebook"
      fill_in "Instagram", with: "@instagram"
      fill_in "Youtube", with: "@youtube"
      fill_in "Question", with: "question"
      fill_in "Proposal summary", with: "Proposal summary"
      fill_in "Link to external video", with: "http://video.com"

      imageable_attach_new_file(create(:image), Rails.root.join("spec/fixtures/files/clippy.jpg"))
      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/empty.pdf"))
      check "legislation_people_proposal_terms_of_service"
      click_button "Create proposal"

      expect(page).to have_content("Thanks!, your proposal was created successfully.")
      expect(page).to have_content("An admin will validate it before be published")

      login_as(admin.user)

      visit admin_legislation_process_people_proposals_path(process)
      click_link "Validate"

      login_as(user)
      visit legislation_process_people_proposals_path(process)
      click_link "Jon Snow"

      expect(page).to have_content "Jon Snow"
      expect(page).to have_content "Proposal summary"
      expect(page).to have_css("img[alt='#{Legislation::PeopleProposal.last.image.title}']")
    end
  end

  scenario "Show votes score on index and show" do
    legislation_proposal_positive = create(:legislation_people_proposal,
                                           :validated,
                                           legislation_process_id: process.id,
                                           title: "Legislation proposal positive")

    legislation_proposal_zero = create(:legislation_people_proposal,
                                       :validated,
                                       legislation_process_id: process.id,
                                       title: "Legislation proposal zero")

    legislation_proposal_negative = create(:legislation_people_proposal,
                                           :validated,
                                           legislation_process_id: process.id,
                                           title: "Legislation proposal negative")

    10.times { create(:vote, votable: legislation_proposal_positive, vote_flag: true) }
    3.times  { create(:vote, votable: legislation_proposal_positive, vote_flag: false) }

    5.times { create(:vote, votable: legislation_proposal_zero, vote_flag: true) }
    5.times  { create(:vote, votable: legislation_proposal_zero, vote_flag: false) }

    6.times  { create(:vote, votable: legislation_proposal_negative, vote_flag: false) }

    visit legislation_process_people_proposals_path(process)

    within "#legislation_people_proposal_#{legislation_proposal_positive.id}" do
      expect(page).to have_content("7 votes")
    end

    within "#legislation_people_proposal_#{legislation_proposal_zero.id}" do
      expect(page).to have_content("No votes")
    end

    within "#legislation_people_proposal_#{legislation_proposal_negative.id}" do
      expect(page).to have_content("-6 votes")
    end

    visit legislation_process_people_proposal_path(process, legislation_proposal_positive)
    expect(page).to have_content("7 votes")

    visit legislation_process_people_proposal_path(process, legislation_proposal_zero)
    expect(page).to have_content("No votes")

    visit legislation_process_people_proposal_path(process, legislation_proposal_negative)
    expect(page).to have_content("-6 votes")
  end

  context "Show page" do
    scenario "display people proposal information" do
      legislation_people_proposal = create(:legislation_people_proposal,
                                             :validated, :with_contact_info,
                                             legislation_process_id: process.id,
                                             title: "Jon Snow")

      visit legislation_process_people_proposals_path(process)

      click_link "Jon Snow"

      expect(page).to have_current_path(legislation_process_people_proposal_path(process,
                                          legislation_people_proposal))
      expect(page).to have_content("Jon Snow")
      expect(page).not_to have_content(legislation_people_proposal.author.name)
      expect(page).to have_content("No comments")
      expect(page).to have_content("Proposal code:")
      expect(page).to have_link("facebook.id", href: "https://www.facebook.com/facebook.id")
      expect(page).to have_link("TwitterId", href: "https://twitter.com/TwitterId")
      expect(page).to have_link("youtubechannelid",
                                  href: "https://www.youtube.com/user/youtubechannelid")
      expect(page).to have_link("instagramid", href: "https://www.instagram.com/instagramid")
      expect(page).to have_content("This law should be implemented by...")
      expect(page).to have_content("Description of the people proposal")
    end
  end
end
