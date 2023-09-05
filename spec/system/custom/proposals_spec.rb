require "rails_helper"

describe "Proposals" do
  context "Index" do
    before do
      Setting["feature.featured_proposals"] = true
      Setting["featured_proposals_number"] = 3
      create_featured_proposals
    end

    scenario "Index view mode is not shown with selected filter" do
      create(:proposal, :selected)

      visit proposals_path

      click_link "View selected proposals"

      expect(page).not_to have_selector(".view-mode")
      expect(page).not_to have_button("View mode")
    end

    scenario "Can visit a proposal from image link" do
      proposal = create(:proposal, :with_image)

      visit proposals_path

      within("#proposal_#{proposal.id}") do
        find("#image").click
      end

      expect(page).to have_current_path(proposal_path(proposal))
    end
  end

  describe "Show sticky support button on small screens", :small_window do
    scenario "After visiting another page" do
      proposal = create(:proposal)

      visit proposal_path(proposal)
      within("#proposal_#{proposal.id}") { click_link "Proposals" }
      click_link proposal.title

      within("#proposal_sticky") do
        expect(page).to have_css(".is-stuck")
        expect(page).not_to have_css(".is-anchored")
      end
    end

    scenario "After using the browser's back button" do
      proposal = create(:proposal)

      visit proposal_path(proposal)
      within("#proposal_#{proposal.id}") { click_link "Proposals" }

      expect(page).to have_link proposal.title

      go_back

      within("#proposal_sticky") do
        expect(page).to have_css(".is-stuck")
        expect(page).not_to have_css(".is-anchored")
      end
    end
  end

  scenario "Create and publish", :with_frozen_time do
    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in_proposal
    fill_in "Tags", with: "Refugees, Solidarity"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    expect(page).to have_content "Help refugees"
    expect(page).not_to have_content "You can also see more information about improving your campaign"

    click_link "No, I want to publish the proposal"

    expect(page).to have_content "Improve your campaign and get more support"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Help refugees"
    expect(page).to have_content "In summary, what we want is..."
    expect(page).to have_content "This is very important because..."
    expect(page.find(:css, "iframe")[:src]).to eq "https://www.youtube.com/embed/yPQfcG-eimk"
    expect(page).to have_content author.name
    expect(page).to have_content "Refugees"
    expect(page).to have_content "Solidarity"
    expect(page).to have_content I18n.l(Date.current)
  end

  scenario "Create with invisible_captcha honeypot field", :no_js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in "Proposal title", with: "I am a bot"
    fill_in "If you are human, ignore this field", with: "This is the honeypot field"
    fill_in "Proposal summary", with: "This is the summary"
    fill_in "Proposal text", with: "This is the description"
    fill_in "Full name of the person submitting the proposal", with: "Some other robot"

    click_button "Create proposal"

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(proposals_path)
  end

  scenario "Create proposal too fast" do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in_proposal

    click_button "Create proposal"

    expect(page).to have_content "Sorry, that was too quick! Please resubmit"

    expect(page).to have_current_path(new_proposal_path)
  end

  scenario "Responsible name is stored for anonymous users" do
    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in_proposal

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    click_link "Dashboard"
    click_link "Edit my proposal"

    within_window(window_opened_by { click_link "Edit proposal" }) do
      expect(page).to have_field "Full name of the person submitting the proposal", with: "Isabel Garcia"
    end
  end

  scenario "Responsible name field is not shown for verified users" do
    author = create(:user, :level_two)
    login_as(author)

    visit new_proposal_path

    expect(page).not_to have_field "Full name of the person submitting the proposal"

    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is very important because..."

    click_button "Create proposal"
    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(Proposal.last.responsible_name).to eq(author.document_number)
  end

  scenario "JS injection is prevented but safe html is respected", :no_js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in "Proposal title", with: "Testing an attack"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in "Proposal text", with: "<p>This is <script>alert('an attack');</script></p>"
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Testing an attack"
    expect(page.html).to include "<p>This is alert('an attack');</p>"
    expect(page.html).not_to include "<script>alert('an attack');</script>"
    expect(page.html).not_to include "&lt;p&gt;This is"
  end

  scenario "Autolinking is applied to description" do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in_new_proposal_title with: "Testing auto link"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is a link www.example.org"
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Testing auto link"
    expect(page).to have_link("www.example.org", href: "http://www.example.org")
  end

  scenario "JS injection is prevented but autolinking is respected", :no_js do
    author = create(:user)
    js_injection_string = "<script>alert('hey')</script> <a href=\"javascript:alert('surprise!')\">click me<a/> http://example.org"
    login_as(author)

    visit new_proposal_path
    fill_in "Proposal title", with: "Testing auto link"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in "Proposal text", with: js_injection_string
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Testing auto link"
    expect(page).to have_link("http://example.org", href: "http://example.org")
    expect(page).not_to have_link("click me")
    expect(page.html).not_to include "<script>alert('hey')</script>"

    click_link "Dashboard"

    within "#side_menu" do
      click_link "Edit my proposal"
    end

    click_link "Edit proposal"

    expect(page).to have_field "Proposal title", with: "Testing auto link"
    expect(page).not_to have_link("click me")
    expect(page.html).not_to include "<script>alert('hey')</script>"
  end

  context "Geozones" do
    scenario "Specific geozone" do
      create(:geozone, name: "California")
      create(:geozone, name: "New York")
      login_as(create(:user))

      visit new_proposal_path

      fill_in_proposal
      select("California", from: "proposal_geozone_id")

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."
      click_link "No, I want to publish the proposal"
      click_link "Not now, go to my proposal"

      within "#geozone" do
        expect(page).to have_content "California"
      end
    end
  end

  describe "Proposal index order filters" do
    scenario "Proposals are ordered by confidence_score" do
      best_proposal = create(:proposal, title: "Best proposal")
      best_proposal.update_column(:confidence_score, 10)
      worst_proposal = create(:proposal, title: "Worst proposal")
      worst_proposal.update_column(:confidence_score, 2)
      medium_proposal = create(:proposal, title: "Medium proposal")
      medium_proposal.update_column(:confidence_score, 5)

      visit proposals_path
      click_link "Highest rated"
      expect(page).to have_selector("a.is-active", text: "Highest rated")

      within "#proposals" do
        expect(best_proposal.title).to appear_before(medium_proposal.title)
        expect(medium_proposal.title).to appear_before(worst_proposal.title)
      end

      expect(page).to have_current_path(/order=confidence_score/)
      expect(page).to have_current_path(/page=1/)
    end

    scenario "Proposals are ordered by newest" do
      best_proposal = create(:proposal, title: "Best proposal", created_at: Time.current)
      medium_proposal = create(:proposal, title: "Medium proposal", created_at: 1.hour.ago)
      worst_proposal = create(:proposal, title: "Worst proposal", created_at: 1.day.ago)

      visit proposals_path
      click_link "Newest"
      expect(page).to have_selector("a.is-active", text: "Newest")

      within "#proposals" do
        expect(best_proposal.title).to appear_before(medium_proposal.title)
        expect(medium_proposal.title).to appear_before(worst_proposal.title)
      end

      expect(page).to have_current_path(/order=created_at/)
      expect(page).to have_current_path(/page=1/)
    end

    context "Recommendations" do
      let!(:best_proposal)   { create(:proposal, title: "Best",   cached_votes_up: 10, tag_list: "Sport") }
      let!(:medium_proposal) { create(:proposal, title: "Medium", cached_votes_up: 5,  tag_list: "Sport") }
      let!(:worst_proposal)  { create(:proposal, title: "Worst",  cached_votes_up: 1,  tag_list: "Sport") }

      scenario "should display text when there are no results" do
        proposal = create(:proposal, tag_list: "Distinct_to_sport")
        user     = create(:user, followables: [proposal])

        login_as(user)
        visit proposals_path

        click_link "Recommendations"

        expect(page).to have_content "There are not proposals related to your interests"
      end

      scenario "should display text when user has no related interests" do
        user = create(:user)

        login_as(user)
        visit proposals_path

        click_link "Recommendations"

        expect(page).to have_content "Follow proposals so we can give you recommendations"
      end

      scenario "can be sorted when there's a logged user" do
        proposal = create(:proposal, tag_list: "Sport")
        user     = create(:user, followables: [proposal])

        login_as(user)
        visit proposals_path

        click_link "Recommendations"

        expect(page).to have_selector("a.is-active", text: "Recommendations")

        within "#proposals-list" do
          expect(best_proposal.title).to appear_before(medium_proposal.title)
          expect(medium_proposal.title).to appear_before(worst_proposal.title)
        end

        expect(page).to have_current_path(/order=recommendations/)
        expect(page).to have_current_path(/page=1/)
      end
    end
  end

  context "Selected Proposals" do
    before do
      create(:proposal, :selected)
      create(:proposal)
    end

    scenario "do not show order links in selected proposals list" do
      visit proposals_path

      expect(page).to have_css  "ul.submenu"
      expect(page).to have_link "Most active"
      expect(page).to have_link "Highest rated"
      expect(page).to have_link "Newest"

      click_link "View selected proposals"

      expect(page).not_to have_css  "ul.submenu"
      expect(page).not_to have_link "Most active"
      expect(page).not_to have_link "Highest rated"
      expect(page).not_to have_link "Newest"
    end
  end

  context "Search" do
    scenario "Order by relevance by default" do
      create(:proposal, title: "In summary", summary: "Title content too", cached_votes_up: 10)
      create(:proposal, title: "Title content", summary: "Summary", cached_votes_up: 1)
      create(:proposal, title: "Title here", summary: "Content here", cached_votes_up: 100)

      visit proposals_path
      fill_in "search", with: "Title content"
      click_button "Search"

      expect(page).to have_selector("a.is-active", text: "Relevance")

      within("#proposals") do
        expect(all(".proposal")[0].text).to match "Title content"
        expect(all(".proposal")[1].text).to match "Title here"
        expect(all(".proposal")[2].text).to match "In summary"
      end
    end

    scenario "Reorder results maintaing search" do
      create(:proposal, title: "Show you got",      cached_votes_up: 10,  created_at: 1.week.ago)
      create(:proposal, title: "Show what you got", cached_votes_up: 1,   created_at: 1.month.ago)
      create(:proposal, title: "Show you got",      cached_votes_up: 100, created_at: Time.current)
      create(:proposal, title: "Do not display",    cached_votes_up: 1,   created_at: 1.week.ago)

      visit proposals_path
      fill_in "search", with: "Show what you got"
      click_button "Search"

      expect(page).to have_content "Search results"

      click_link "Newest"

      expect(page).to have_selector("a.is-active", text: "Newest")

      within("#proposals") do
        expect(all(".proposal")[0].text).to match "Show you got"
        expect(all(".proposal")[1].text).to match "Show you got"
        expect(all(".proposal")[2].text).to match "Show what you got"
        expect(page).not_to have_content "Do not display"
      end
    end

    scenario "Reorder by recommendations results maintaing search" do
      user = create(:user, recommended_proposals: true)

      create(:proposal, title: "Show you got",      cached_votes_up: 10,  tag_list: "Sport")
      create(:proposal, title: "Show what you got", cached_votes_up: 1,   tag_list: "Sport")
      create(:proposal, title: "Do not display with same tag", cached_votes_up: 100, tag_list: "Sport")
      create(:proposal, title: "Do not display",    cached_votes_up: 1)
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit proposals_path
      fill_in "search", with: "Show you got"
      click_button "Search"
      click_link "Recommendations"
      expect(page).to have_selector("a.is-active", text: "Recommendations")

      within("#proposals") do
        expect(all(".proposal")[0].text).to match "Show you got"
        expect(all(".proposal")[1].text).to match "Show what you got"
        expect(page).not_to have_content "Do not display with same tag"
        expect(page).not_to have_content "Do not display"
      end
    end
  end

  context "Suggesting proposals" do
    scenario "Show up to 5 suggestions" do
      create(:proposal, title: "First proposal, has search term")
      create(:proposal, title: "Second title")
      create(:proposal, title: "Third proposal, has search term")
      create(:proposal, title: "Fourth proposal, has search term")
      create(:proposal, title: "Fifth proposal, has search term")
      create(:proposal, title: "Sixth proposal, has search term")
      create(:proposal, title: "Seventh proposal, has search term")

      login_as(create(:user))
      visit new_proposal_path
      fill_in "Proposal title", with: "search"

      within("div.js-suggest") do
        expect(page).to have_content "You are seeing 5 of 6 proposals containing the term 'search'"
      end
    end

    scenario "No found suggestions" do
      create(:proposal, title: "First proposal").update_column(:confidence_score, 10)
      create(:proposal, title: "Second proposal").update_column(:confidence_score, 8)

      login_as(create(:user))
      visit new_proposal_path
      fill_in "Proposal title", with: "debate"

      within("div.js-suggest") do
        expect(page).not_to have_content "You are seeing"
      end
    end
  end

  context "Skip user verification" do
    before do
      Setting["feature.user.skip_verification"] = "true"
    end

    scenario "Create" do
      author = create(:user)
      login_as(author)

      visit proposals_path

      within("aside") do
        click_link "Create a proposal"
      end

      expect(page).to have_current_path(new_proposal_path)

      fill_in_new_proposal_title with: "Help refugees"
      fill_in "Proposal summary", with: "In summary what we want is..."
      fill_in_ckeditor "Proposal text", with: "This is very important because..."
      fill_in "External video URL", with: "https://www.youtube.com/watch?v=yPQfcG-eimk"
      fill_in "Tags", with: "Refugees, Solidarity"

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."
    end
  end

  describe "SDG related list" do
    let(:user) { create(:user) }

    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.proposals"] = true
    end

    scenario "create proposal with sdg related list" do
      login_as(user)
      visit new_proposal_path
      fill_in_new_proposal_title with: "A title for a proposal related with SDG related content"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"
      click_sdg_goal(1)

      click_button "Create proposal"

      within(".sdg-goal-tag-list") { expect(page).to have_link "1. No Poverty" }
    end
  end
end
