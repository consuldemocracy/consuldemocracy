require "rails_helper"
require "sessions_helper"

describe "Legislation Proposals" do
  let(:user)     { create(:user) }
  let(:process)  { create(:legislation_process) }
  let(:proposal) { create(:legislation_proposal) }

  context "Concerns" do
    it_behaves_like "notifiable in-app", :legislation_proposal
    it_behaves_like "flaggable", :legislation_proposal
  end

  scenario "Only one menu element has 'active' CSS selector" do
    visit legislation_process_proposal_path(proposal.process, proposal)

    within("#navigation_bar") do
      expect(page).to have_css(".is-active", count: 1)
    end
  end

  describe "Random pagination" do
    let(:per_page) { 4 }

    before do
      allow(Legislation::Proposal).to receive(:default_per_page).and_return(per_page)

      create_list(
        :legislation_proposal,
        Legislation::Proposal.default_per_page + 2,
        process: process
      )
    end

    context "for several users" do
      let(:user2)    { create(:user) }
      let(:per_page) { 12 }

      scenario "Each user has a different and consistent random proposals order" do
        first_user_proposals_order = nil
        second_user_proposals_order = nil

        in_browser(:one) do
          login_as user
          visit legislation_process_proposals_path(process)
          first_user_proposals_order = legislation_proposals_order
        end

        in_browser(:two) do
          login_as user2
          visit legislation_process_proposals_path(process)
          second_user_proposals_order = legislation_proposals_order
        end

        expect(first_user_proposals_order).not_to eq(second_user_proposals_order)

        in_browser(:one) do
          visit legislation_process_proposals_path(process)
          expect(legislation_proposals_order).to eq(first_user_proposals_order)
        end

        in_browser(:two) do
          visit legislation_process_proposals_path(process)
          expect(legislation_proposals_order).to eq(second_user_proposals_order)
        end
      end
    end

    scenario "Random order maintained with pagination" do
      login_as user
      visit legislation_process_proposals_path(process)
      first_page_proposals_order = legislation_proposals_order

      click_link "Next"

      expect(page).to have_content "You're on page\n2"
      expect(first_page_proposals_order & legislation_proposals_order).to eq([])

      click_link "Previous"

      expect(page).to have_content "You're on page\n1"
      expect(legislation_proposals_order).to eq(first_page_proposals_order)
    end

    scenario "Does not crash when the seed is not a number" do
      login_as user
      visit legislation_process_proposals_path(process, random_seed: "Spoof")

      expect(page).to have_content "Random"
    end
  end

  context "Selected filter" do
    scenario "apperars even if there are not any selected poposals" do
      create(:legislation_proposal, legislation_process_id: process.id)

      visit legislation_process_proposals_path(process)

      expect(page).to have_content("Selected")
    end

    scenario "defaults to winners if there are selected proposals" do
      create(:legislation_proposal, legislation_process_id: process.id)
      create(:legislation_proposal, legislation_process_id: process.id, selected: true)

      visit legislation_process_proposals_path(process)

      expect(page).to have_link("Random")
      expect(page).not_to have_link("Selected")
      expect(page).to have_content("Selected")
    end

    scenario "defaults to random if the current process does not have selected proposals" do
      create(:legislation_proposal, legislation_process_id: process.id)
      create(:legislation_proposal, selected: true)

      visit legislation_process_proposals_path(process)

      expect(page).to have_link("Selected")
      expect(page).not_to have_link("Random")
      expect(page).to have_content("Random")
    end

    scenario "filters correctly" do
      proposal1 = create(:legislation_proposal, legislation_process_id: process.id)
      proposal2 = create(:legislation_proposal, legislation_process_id: process.id, selected: true)

      visit legislation_process_proposals_path(process, filter: "random")
      click_link "Selected"

      expect(page).to have_css("div#legislation_proposal_#{proposal2.id}")
      expect(page).not_to have_css("div#legislation_proposal_#{proposal1.id}")
    end
  end

  def legislation_proposals_order
    all("[id^='legislation_proposal_']").map { |e| e[:id] }
  end

  scenario "Create a legislation proposal with an image" do
    create(:legislation_proposal, process: process)

    login_as user

    visit new_legislation_process_proposal_path(process)

    fill_in "Proposal title", with: "Legislation proposal with image"
    fill_in "Proposal summary", with: "Including an image on a legislation proposal"
    imageable_attach_new_file(file_fixture("clippy.jpg"))
    check "legislation_proposal_terms_of_service"
    click_button "Create proposal"

    expect(page).to have_content "Legislation proposal with image"
    expect(page).to have_content "Including an image on a legislation proposal"
    expect(page).to have_css "img[alt='clippy.jpg']"
  end

  scenario "Show votes score on index and show" do
    legislation_proposal_positive = create(:legislation_proposal,
                                           legislation_process_id: process.id,
                                           title: "Legislation proposal positive")

    legislation_proposal_zero = create(:legislation_proposal,
                                       legislation_process_id: process.id,
                                       title: "Legislation proposal zero")

    legislation_proposal_negative = create(:legislation_proposal,
                                           legislation_process_id: process.id,
                                           title: "Legislation proposal negative")

    10.times { create(:vote, votable: legislation_proposal_positive, vote_flag: true) }
    3.times  { create(:vote, votable: legislation_proposal_positive, vote_flag: false) }

    5.times { create(:vote, votable: legislation_proposal_zero, vote_flag: true) }
    5.times  { create(:vote, votable: legislation_proposal_zero, vote_flag: false) }

    6.times  { create(:vote, votable: legislation_proposal_negative, vote_flag: false) }

    visit legislation_process_proposals_path(process)

    within "#legislation_proposal_#{legislation_proposal_positive.id}" do
      expect(page).to have_content("7 votes")
    end

    within "#legislation_proposal_#{legislation_proposal_zero.id}" do
      expect(page).to have_content("No votes")
    end

    within "#legislation_proposal_#{legislation_proposal_negative.id}" do
      expect(page).to have_content("-6 votes")
    end

    visit legislation_process_proposal_path(process, legislation_proposal_positive)
    expect(page).to have_content("7 votes")

    visit legislation_process_proposal_path(process, legislation_proposal_zero)
    expect(page).to have_content("No votes")

    visit legislation_process_proposal_path(process, legislation_proposal_negative)
    expect(page).to have_content("-6 votes")
  end

  scenario "Show link to process on show" do
    create(:legislation_proposal, legislation_process_id: process.id)

    visit legislation_process_proposal_path(proposal.process, proposal)

    within(".process-proposal") do
      expect(page).to have_content("COLLABORATIVE LEGISLATION PROCESS")
      expect(page).to have_link(process.title)
    end
  end

  scenario "Shows proposal tags as proposals filter" do
    create(:legislation_proposal, process: process, tag_list: "Culture", title: "Open concert")
    create(:legislation_proposal, process: process, tag_list: "Sports", title: "Baseball field")

    visit legislation_process_proposals_path(process)

    expect(page).to have_content "Open concert"
    expect(page).to have_content "Baseball field"

    click_link "Culture"

    expect(page).not_to have_content "Baseball field"
    expect(page).to have_content "Open concert"
  end

  scenario "Show proposal tags on show when SDG is enabled" do
    Setting["feature.sdg"] = true
    Setting["sdg.process.legislation"] = true

    proposal = create(:legislation_proposal, process: process, tag_list: "Culture")

    visit legislation_process_proposal_path(proposal.process, proposal)

    expect(page).to have_link("Culture")
  end

  scenario "Shows geozone tag as proposals filter where there are geozones defined" do
    create(:legislation_proposal, process: process)
    create(:legislation_proposal, process: process, geozone: create(:geozone, name: "Zone1"))

    visit legislation_process_proposals_path(process)

    expect(page).to have_link("Zone1", href: legislation_process_proposals_path(process, search: "Zone1"))
    link = legislation_process_proposals_path(process, search: "All city")
    expect(page).to have_link("All city", href: link)
  end

  scenario "Does not show the geozone tag when no geozones defined" do
    create(:legislation_proposal, process: process)

    visit legislation_process_proposals_path(process)

    expect(page).not_to have_link("All city")
  end

  scenario "Can filter proposals by geozone" do
    geozone = create(:geozone, name: "Zone1")
    proposal = create(:legislation_proposal, title: "Proposal with geozone",
                                             legislation_process_id: process.id,
                                             geozone: geozone)
    create(:legislation_proposal, title: "Proposal without geozone", legislation_process_id: process.id)

    visit legislation_process_proposal_path(proposal.process, proposal)
    click_link "Zone1"

    expect(page).to have_current_path(legislation_process_proposals_path(process.id, search: "Zone1"))
    expect(page).to have_content("Proposal with geozone")
    expect(page).not_to have_content("Proposal without geozone")
  end

  scenario "Show link to filter by geozone where there are geozones defined" do
    create(:geozone)
    create(:legislation_proposal, legislation_process_id: process.id)

    visit legislation_process_proposal_path(proposal.process, proposal)

    expect(page).to have_link("All city")
  end

  scenario "Do not show link to geozone where there are no geozones defined" do
    create(:legislation_proposal, legislation_process_id: process.id)

    visit legislation_process_proposal_path(proposal.process, proposal)

    expect(page).not_to have_link("All city")
  end

  scenario "form shows the geozone selector when there are geozones defined" do
    create(:geozone)
    login_as user

    visit new_legislation_process_proposal_path(process)

    expect(page).to have_field("Scope of operation")
  end

  scenario "form do not show geozone selector when there are no geozones defined" do
    login_as user

    visit new_legislation_process_proposal_path(process)

    expect(page).not_to have_field("Scope of operation")
  end

  context "Embedded video" do
    scenario "Show YouTube video" do
      proposal = create(:legislation_proposal, video_url: "http://www.youtube.com/watch?v=a7UFm6ErMPU")

      visit legislation_process_proposal_path(proposal.process, proposal)

      within "#js-embedded-video" do
        expect(page).to have_css "iframe[src='https://www.youtube-nocookie.com/embed/a7UFm6ErMPU']"
      end
    end

    scenario "Show Vimeo video" do
      proposal = create(:legislation_proposal, video_url: "https://vimeo.com/7232823")

      visit legislation_process_proposal_path(proposal.process, proposal)

      within "#js-embedded-video" do
        expect(page).to have_css "iframe[src='https://player.vimeo.com/video/7232823?dnt=1']"
      end
    end

    scenario "Dont show video" do
      proposal = create(:legislation_proposal, video_url: nil)

      visit legislation_process_proposal_path(proposal.process, proposal)

      expect(page).not_to have_css "#js-embedded-video"
    end
  end
end
