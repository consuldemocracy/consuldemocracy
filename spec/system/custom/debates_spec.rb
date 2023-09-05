require "rails_helper"

describe "Debates" do
  scenario "Show total votes on index and show" do
    debate_with_postive_votes = create(:debate, title: "Liked Debate")
    2.times { create(:vote, votable: debate_with_postive_votes, vote_flag: true) }

    debate_with_negative_votes = create(:debate, title: "Unliked Debate")
    3.times { create(:vote, votable: debate_with_negative_votes, vote_flag: false) }

    debate_with_both_votes = create(:debate, title: "Voted Debate")
    3.times { create(:vote, votable: debate_with_both_votes, vote_flag: true) }
    2.times { create(:vote, votable: debate_with_both_votes, vote_flag: false) }

    debate_without_votes = create(:debate, title: "Unvoted Debate")

    visit debates_path

    within "#debate_#{debate_with_postive_votes.id}" do
      expect(page).to have_content("2 votes")
    end

    within "#debate_#{debate_with_negative_votes.id}" do
      expect(page).to have_content("3 votes")
    end

    within "#debate_#{debate_with_both_votes.id}" do
      expect(page).to have_content("5 votes")
    end

    within "#debate_#{debate_without_votes.id}" do
      expect(page).to have_content("No votes")
    end

    visit debate_path(debate_with_postive_votes)
    expect(page).to have_content("2 votes")

    visit debate_path(debate_with_negative_votes)
    expect(page).to have_content("3 votes")

    visit debate_path(debate_with_both_votes)
    expect(page).to have_content("5 votes")

    visit debate_path(debate_without_votes)
    expect(page).to have_content("No votes")
  end

  scenario "Create", :with_frozen_time do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in_new_debate_title with: "A title for a debate"
    fill_in_ckeditor "Initial debate text", with: "This is very important because..."

    click_button "Start a debate"

    expect(page).to have_content "A title for a debate"
    expect(page).to have_content "Debate created successfully."
    expect(page).to have_content "This is very important because..."
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Date.current)
  end

  scenario "Create with invisible_captcha honeypot field", :no_js do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in "Debate title", with: "I am a bot"
    fill_in "debate_subtitle", with: "This is a honeypot field"
    fill_in "Initial debate text", with: "This is the description"

    click_button "Start a debate"

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(debates_path)
  end

  scenario "Create debate too fast" do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in_new_debate_title with: "I am a bot"
    fill_in_ckeditor "Initial debate text", with: "This is the description"

    click_button "Start a debate"

    expect(page).to have_content "Sorry, that was too quick! Please resubmit"

    expect(page).to have_current_path(new_debate_path)
  end

  scenario "JS injection is prevented but safe html is respected", :no_js do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in "Debate title", with: "Testing an attack"
    fill_in "Initial debate text", with: "<p>This is a JS <script>alert('an attack');</script></p>"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_content "Testing an attack"
    expect(page.html).to include "<p>This is a JS alert('an attack');</p>"
    expect(page.html).not_to include "<script>alert('an attack');</script>"
    expect(page.html).not_to include "&lt;p&gt;This is"
  end

  scenario "Autolinking is applied to description" do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in_new_debate_title with: "Testing auto link"
    fill_in_ckeditor "Initial debate text", with: "This is a link www.example.org"

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_content "Testing auto link"
    expect(page).to have_link("www.example.org", href: "http://www.example.org")
  end

  scenario "JS injection is prevented but autolinking is respected", :no_js do
    author = create(:user)
    js_injection_string = "<script>alert('hey')</script> <a href=\"javascript:alert('surprise!')\">click me<a/> http://example.org"
    login_as(author)

    visit new_debate_path
    fill_in "Debate title", with: "Testing auto link"
    fill_in "Initial debate text", with: js_injection_string

    click_button "Start a debate"

    expect(page).to have_content "Debate created successfully."
    expect(page).to have_content "Testing auto link"
    expect(page).to have_link("http://example.org", href: "http://example.org")
    expect(page).not_to have_link("click me")
    expect(page.html).not_to include "<script>alert('hey')</script>"

    click_link "Edit"

    expect(page).to have_css "h1", exact_text: "Edit debate"
    expect(page).to have_field "Debate title", with: "Testing auto link"
    expect(page).not_to have_link("click me")
    expect(page.html).not_to include "<script>alert('hey')</script>"
  end

  describe "Debate index order filters" do
    scenario "Debates are ordered by confidence_score" do
      best_debate = create(:debate, title: "Best")
      best_debate.update_column(:confidence_score, 10)
      worst_debate = create(:debate, title: "Worst")
      worst_debate.update_column(:confidence_score, 2)
      medium_debate = create(:debate, title: "Medium")
      medium_debate.update_column(:confidence_score, 5)

      visit debates_path
      click_link "Highest rated"

      expect(page).to have_selector("a.is-active", text: "Highest rated")

      within "#debates" do
        expect(best_debate.title).to appear_before(medium_debate.title)
        expect(medium_debate.title).to appear_before(worst_debate.title)
      end

      expect(page).to have_current_path(/order=confidence_score/)
      expect(page).to have_current_path(/page=1/)
    end

    scenario "Debates are ordered by newest" do
      best_debate = create(:debate, title: "Best", created_at: Time.current)
      medium_debate = create(:debate, title: "Medium", created_at: 1.hour.ago)
      worst_debate = create(:debate, title: "Worst", created_at: 1.day.ago)

      visit debates_path
      click_link "Newest"

      expect(page).to have_selector("a.is-active", text: "Newest")

      within "#debates" do
        expect(best_debate.title).to appear_before(medium_debate.title)
        expect(medium_debate.title).to appear_before(worst_debate.title)
      end

      expect(page).to have_current_path(/order=created_at/)
      expect(page).to have_current_path(/page=1/)
    end

    context "Recommendations" do
      let!(:best_debate)   { create(:debate, title: "Best",   cached_votes_total: 10, tag_list: "Sport") }
      let!(:medium_debate) { create(:debate, title: "Medium", cached_votes_total: 5,  tag_list: "Sport") }
      let!(:worst_debate)  { create(:debate, title: "Worst",  cached_votes_total: 1,  tag_list: "Sport") }

      scenario "should display text when there are no results" do
        proposal = create(:proposal, tag_list: "Distinct_to_sport")
        user     = create(:user, followables: [proposal])

        login_as(user)
        visit debates_path

        click_link "Recommendations"

        expect(page).to have_content "There are no debates related to your interests"
      end

      scenario "should display text when user has no related interests" do
        user = create(:user)

        login_as(user)
        visit debates_path

        click_link "Recommendations"

        expect(page).to have_content "Follow proposals so we can give you recommendations"
      end

      scenario "can be sorted when there's a logged user" do
        proposal = create(:proposal, tag_list: "Sport")
        user     = create(:user, followables: [proposal])

        login_as(user)
        visit debates_path

        click_link "Recommendations"

        expect(page).to have_selector("a.is-active", text: "Recommendations")

        within "#debates" do
          expect(best_debate.title).to appear_before(medium_debate.title)
          expect(medium_debate.title).to appear_before(worst_debate.title)
        end

        expect(page).to have_current_path(/order=recommendations/)
        expect(page).to have_current_path(/page=1/)
      end
    end
  end

  context "Search" do
    scenario "Order by relevance by default" do
      create(:debate, title: "Show you got",      cached_votes_up: 10)
      create(:debate, title: "Show what you got", cached_votes_up: 1)
      create(:debate, title: "Show you got",      cached_votes_up: 100)

      visit debates_path
      fill_in "search", with: "Show you got"
      click_button "Search"

      expect(page).to have_selector("a.is-active", text: "Relevance")

      within("#debates") do
        expect(all(".debate")[0].text).to match "Show you got"
        expect(all(".debate")[1].text).to match "Show you got"
        expect(all(".debate")[2].text).to match "Show what you got"
      end
    end

    scenario "Reorder results maintaing search" do
      create(:debate, title: "Show you got",      cached_votes_up: 10,  created_at: 1.week.ago)
      create(:debate, title: "Show what you got", cached_votes_up: 1,   created_at: 1.month.ago)
      create(:debate, title: "Show you got",      cached_votes_up: 100, created_at: Time.current)
      create(:debate, title: "Do not display",    cached_votes_up: 1,   created_at: 1.week.ago)

      visit debates_path
      fill_in "search", with: "Show you got"
      click_button "Search"
      click_link "Newest"
      expect(page).to have_selector("a.is-active", text: "Newest")

      within("#debates") do
        expect(all(".debate")[0].text).to match "Show you got"
        expect(all(".debate")[1].text).to match "Show you got"
        expect(all(".debate")[2].text).to match "Show what you got"
        expect(page).not_to have_content "Do not display"
      end
    end

    scenario "Reorder by recommendations results maintaing search" do
      proposal = create(:proposal, tag_list: "Sport")
      user = create(:user, recommended_debates: true, followables: [proposal])

      create(:debate, title: "Show you got",      cached_votes_total: 10,  tag_list: "Sport")
      create(:debate, title: "Show what you got", cached_votes_total: 1,   tag_list: "Sport")
      create(:debate, title: "Do not display with same tag", cached_votes_total: 100, tag_list: "Sport")
      create(:debate, title: "Do not display",    cached_votes_total: 1)

      login_as(user)
      visit debates_path
      fill_in "search", with: "Show you got"
      click_button "Search"
      click_link "Recommendations"
      expect(page).to have_selector("a.is-active", text: "Recommendations")

      within("#debates") do
        expect(all(".debate")[0].text).to match "Show you got"
        expect(all(".debate")[1].text).to match "Show what you got"
        expect(page).not_to have_content "Do not display with same tag"
        expect(page).not_to have_content "Do not display"
      end
    end
  end

  context "Suggesting debates" do
    scenario "Shows up to 5 suggestions" do
      create(:debate, title: "First debate has 1 vote", cached_votes_up: 1)
      create(:debate, title: "Second debate has 2 votes", cached_votes_up: 2)
      create(:debate, title: "Third debate has 3 votes", cached_votes_up: 3)
      create(:debate, title: "This one has 4 votes", description: "This is the fourth debate", cached_votes_up: 4)
      create(:debate, title: "Fifth debate has 5 votes", cached_votes_up: 5)
      create(:debate, title: "Sixth debate has 6 votes", description: "This is the sixth debate",  cached_votes_up: 6)
      create(:debate, title: "This has seven votes, and is not suggest", description: "This is the seven", cached_votes_up: 7)

      login_as(create(:user))
      visit new_debate_path
      fill_in "Debate title", with: "debate"

      within("div.js-suggest") do
        expect(page).to have_content "You are seeing 5 of 6 debates containing the term 'debate'"
      end
    end

    scenario "No found suggestions" do
      create(:debate, title: "First debate has 10 vote", cached_votes_up: 10)
      create(:debate, title: "Second debate has 2 votes", cached_votes_up: 2)

      login_as(create(:user))
      visit new_debate_path
      fill_in "Debate title", with: "proposal"

      within("div.js-suggest") do
        expect(page).not_to have_content "You are seeing"
      end
    end
  end

  scenario "Mark and unmark as featured" do
    debate = create(:debate, title: "Featured debate")
    admin = create(:administrator)

    login_as(admin.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      click_link "Featured"
    end

    page.driver.browser.switch_to.alert do
      expect(page).to have_content "Are you sure? This action will mark this debate as featured and "\
                                   "will be displayed on the main debates page."
    end

    accept_confirm
    expect(page).to have_current_path(debates_path)
    expect(debate.reload.featured?).to be true

    within("#featured-debates") do
      expect(page).to have_content("Featured debate")
    end

    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      expect(page).not_to have_link("Featured")
      click_link "Unmark featured"
    end

    page.driver.browser.switch_to.alert do
      expect(page).to have_content "Are you sure? This action will unmark this debate as featured and "\
                                   "will be hidden from the main debates page."
    end

    accept_confirm
    expect(page).to have_current_path(debates_path)
    expect(debate.reload.featured?).to be false

    expect(page).not_to have_selector("#featured-debates")
  end

  describe "SDG related list" do
    let(:user) { create(:user) }

    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.debates"] = true
    end

    scenario "create debate with sdg related list" do
      login_as(user)
      visit new_debate_path
      fill_in_new_debate_title with: "A title for a debate related with SDG related content"
      fill_in_ckeditor "Initial debate text", with: "This is very important because..."
      click_sdg_goal(1)

      click_button "Start a debate"

      within(".sdg-goal-tag-list") { expect(page).to have_link "1. No Poverty" }
    end
  end
end
