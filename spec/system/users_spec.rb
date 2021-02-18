require "rails_helper"

describe "Users" do
  describe "Show (public page)" do
    let(:user) { create(:user) }

    before do
      1.times { create(:debate, author: user) }
      2.times { create(:proposal, author: user) }
      3.times { create(:budget_investment, author: user) }
      4.times { create(:comment, user: user) }

      visit user_path(user)
    end

    scenario "shows user public activity" do
      expect(page).to have_content("1 Debate")
      expect(page).to have_content("2 Proposals")
      expect(page).to have_content("3 Investments")
      expect(page).to have_content("4 Comments")
    end

    scenario "shows only items where user has activity" do
      user.proposals.destroy_all

      expect(page).not_to have_content("0 Proposals")
      expect(page).to have_content("1 Debate")
      expect(page).to have_content("3 Investments")
      expect(page).to have_content("4 Comments")
    end

    scenario "default filter is proposals" do
      user.proposals.each do |proposal|
        expect(page).to have_content(proposal.title)
      end

      user.debates.each do |debate|
        expect(page).not_to have_content(debate.title)
      end

      user.comments.each do |comment|
        expect(page).not_to have_content(comment.body)
      end
    end

    scenario "shows debates by default if user has no proposals" do
      user.proposals.destroy_all
      visit user_path(user)

      expect(page).to have_content(user.debates.first.title)
    end

    scenario "shows investments by default if user has no proposals nor debates" do
      user.proposals.destroy_all
      user.debates.destroy_all
      visit user_path(user)

      expect(page).to have_content(user.budget_investments.first.title)
    end

    scenario "shows comments by default if user has no proposals nor debates nor investments" do
      user.proposals.destroy_all
      user.debates.destroy_all
      user.budget_investments.destroy_all
      visit user_path(user)

      user.comments.each do |comment|
        expect(page).to have_content(comment.body)
      end
    end

    scenario "filters" do
      click_link "1 Debate"

      user.debates.each do |debate|
        expect(page).to have_content(debate.title)
      end

      user.proposals.each do |proposal|
        expect(page).not_to have_content(proposal.title)
      end

      user.comments.each do |comment|
        expect(page).not_to have_content(comment.body)
      end

      click_link "4 Comments"

      user.comments.each do |comment|
        expect(page).to have_content(comment.body)
      end

      user.proposals.each do |proposal|
        expect(page).not_to have_content(proposal.title)
      end

      user.debates.each do |debate|
        expect(page).not_to have_content(debate.title)
      end

      click_link "2 Proposals"

      user.proposals.each do |proposal|
        expect(page).to have_content(proposal.title)
      end

      user.comments.each do |comment|
        expect(page).not_to have_content(comment.body)
      end

      user.debates.each do |debate|
        expect(page).not_to have_content(debate.title)
      end
    end

    scenario "Show alert when user wants to delete a budget investment", :js do
      user = create(:user, :level_two)
      budget = create(:budget, :accepting)
      budget_investment = create(:budget_investment, author_id: user.id, budget: budget)

      login_as(user)
      visit user_path(user)

      expect(page).to have_link budget_investment.title

      within("#budget_investment_#{budget_investment.id}") do
        dismiss_confirm { click_link "Delete" }
      end
      expect(page).to have_link budget_investment.title

      within("#budget_investment_#{budget_investment.id}") do
        accept_confirm { click_link "Delete" }
      end
      expect(page).not_to have_link budget_investment.title
    end
  end

  describe "Public activity" do
    let(:user) { create(:user) }

    scenario "visible by default" do
      visit user_path(user)

      expect(page).to have_content(user.username)
      expect(page).not_to have_content("activity list private")
    end

    scenario "user can hide public page" do
      login_as(user)
      visit account_path

      uncheck "account_public_activity"
      click_button "Save changes"

      logout

      visit user_path(user)
      expect(page).to have_content("activity list private")
    end

    scenario "is always visible for the owner" do
      login_as(user)
      visit account_path

      uncheck "account_public_activity"
      click_button "Save changes"

      visit user_path(user)
      expect(page).not_to have_content("activity list private")
    end

    scenario "is always visible for admins" do
      login_as(user)
      visit account_path

      uncheck "account_public_activity"
      click_button "Save changes"

      logout

      login_as(create(:administrator).user)
      visit user_path(user)
      expect(page).not_to have_content("activity list private")
    end

    scenario "is always visible for moderators" do
      login_as(user)
      visit account_path

      uncheck "account_public_activity"
      click_button "Save changes"

      logout

      login_as(create(:moderator).user)
      visit user_path(user)
      expect(page).not_to have_content("activity list private")
    end

    describe "User email" do
      let(:user) { create(:user) }

      scenario "is not shown if no user logged in" do
        visit user_path(user)
        expect(page).not_to have_content(user.email)
      end

      scenario "is not shown if logged in user is a regular user" do
        login_as(create(:user))
        visit user_path(user)
        expect(page).not_to have_content(user.email)
      end

      scenario "is not shown if logged in user is moderator" do
        login_as(create(:moderator).user)
        visit user_path(user)
        expect(page).not_to have_content(user.email)
      end

      scenario "is shown if logged in user is admin", :admin do
        visit user_path(user)
        expect(page).to have_content(user.email)
      end
    end
  end

  describe "Public interests" do
    let(:user) { create(:user) }

    scenario "Display interests" do
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit account_path

      check "account_public_interests"
      click_button "Save changes"

      logout

      visit user_path(user)
      expect(page).to have_content("Sport")
    end

    scenario "Not display interests when proposal has been destroyed" do
      proposal = create(:proposal, tag_list: "Sport", followers: [user])
      proposal.destroy!

      login_as(user)
      visit account_path

      check "account_public_interests"
      click_button "Save changes"

      logout

      visit user_path(user)
      expect(page).not_to have_content("Sport")
    end

    scenario "No visible by default" do
      visit user_path(user)

      expect(page).to have_content(user.username)
      expect(page).not_to have_css("#public_interests")
    end

    scenario "User can display public page" do
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit account_path

      check "account_public_interests"
      click_button "Save changes"

      logout

      visit user_path(user, filter: "follows", page: "1")

      expect(page).to have_css("#public_interests")
    end

    scenario "Is always visible for the owner" do
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit account_path

      uncheck "account_public_interests"
      click_button "Save changes"

      visit user_path(user, filter: "follows", page: "1")
      expect(page).to have_css("#public_interests")
    end

    scenario "Is always visible for admins" do
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit account_path

      uncheck "account_public_interests"
      click_button "Save changes"

      logout

      login_as(create(:administrator).user)
      visit user_path(user, filter: "follows", page: "1")
      expect(page).to have_css("#public_interests")
    end

    scenario "Is always visible for moderators" do
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit account_path

      uncheck "account_public_interests"
      click_button "Save changes"

      logout

      login_as(create(:moderator).user)
      visit user_path(user, filter: "follows", page: "1")
      expect(page).to have_css("#public_interests")
    end

    scenario "Should display generic interests title" do
      create(:proposal, tag_list: "Sport", followers: [user])

      user.update!(public_interests: true)
      visit user_path(user, filter: "follows", page: "1")

      expect(page).to have_content("Tags of elements this user follows")
    end

    scenario "Should display custom interests title when user is visiting own user page" do
      create(:proposal, tag_list: "Sport", followers: [user])

      user.update!(public_interests: true)
      login_as(user)
      visit user_path(user, filter: "follows", page: "1")

      expect(page).to have_content("Tags of elements you follow")
    end
  end

  describe "Special comments" do
    scenario "comments posted as moderator are not visible in user activity" do
      moderator = create(:administrator).user
      comment = create(:comment, user: moderator)
      moderator_comment = create(:comment, user: moderator, moderator_id: moderator.id)

      visit user_path(moderator)
      expect(page).to have_content("1 Comment")
      expect(page).to have_content(comment.body)
      expect(page).not_to have_content(moderator_comment.body)
    end

    scenario "comments posted as admin are not visible in user activity" do
      admin = create(:administrator).user
      comment = create(:comment, user: admin)
      admin_comment = create(:comment, user: admin, administrator_id: admin.id)

      visit user_path(admin)
      expect(page).to have_content(comment.body)
      expect(page).not_to have_content(admin_comment.body)
    end

    scenario "valuation comments are not visible in user activity" do
      admin = create(:administrator).user
      comment = create(:comment, user: admin)
      investment = create(:budget_investment)
      valuation_comment = create(:comment, :valuation, user: admin, commentable: investment)

      visit user_path(admin)
      expect(page).to have_content(comment.body)
      expect(page).not_to have_content(valuation_comment.body)
    end

    scenario "shows only comments from active features" do
      user = create(:user)
      1.times { create(:comment, user: user, commentable: create(:debate)) }
      2.times { create(:comment, user: user, commentable: create(:budget_investment)) }
      4.times { create(:comment, user: user, commentable: create(:proposal)) }

      visit user_path(user)
      expect(page).to have_content("7 Comments")

      Setting["process.debates"] = nil
      visit user_path(user)
      expect(page).to have_content("6 Comments")

      Setting["process.budgets"] = nil
      visit user_path(user)
      expect(page).to have_content("4 Comments")
    end
  end

  describe "Following (public page)" do
    let(:user) { create(:user) }

    scenario "Do not display follows' tab when user is not following any followables" do
      visit user_path(user)

      expect(page).not_to have_content("0 Following")
    end

    scenario "Active following tab by default when follows filters selected", :js do
      create(:proposal, author: user, followers: [user])

      visit user_path(user, filter: "follows")

      expect(page).to have_selector(".activity li.is-active", text: "1 Following")
    end

    scenario "Gracefully handle followables that have been hidden" do
      create(:proposal, followers: [user])
      create(:proposal, followers: [user], &:hide)

      visit user_path(user)

      expect(page).to have_content("1 Following")
    end

    describe "Proposals" do
      scenario "Display following tab when user is following one proposal at least" do
        create(:proposal, followers: [user])

        visit user_path(user)

        expect(page).to have_content("1 Following")
      end

      scenario "Display proposal tab when user is following one proposal at least" do
        create(:proposal, followers: [user])

        visit user_path(user, filter: "follows")

        expect(page).to have_link("Citizen proposals", href: "#citizen_proposals")
      end

      scenario "Do not display proposals' tab when user is not following any proposal" do
        visit user_path(user, filter: "follows")

        expect(page).not_to have_link("Citizen proposals", href: "#citizen_proposals")
      end

      scenario "Display proposals with link to proposal" do
        proposal = create(:proposal, author: user, followers: [user])

        login_as user

        visit user_path(user, filter: "follows")
        click_link "Citizen proposals"

        expect(page).to have_content proposal.title
      end

      scenario "Retired proposals do not have a link to the dashboard", js: true do
        proposal = create(:proposal, :retired, author: user)
        login_as user

        visit user_path(user)

        expect(page).to have_content proposal.title
        expect(page).not_to have_link "Dashboard"
        expect(page).to have_content("Dashboard not available for retired proposals")
      end

      scenario "Published proposals have a link to the dashboard" do
        proposal = create(:proposal, :published, author: user)
        login_as user

        visit user_path(user)

        expect(page).to have_content proposal.title
        expect(page).to have_link "Dashboard"
      end
    end

    describe "Budget Investments" do
      scenario "Display following tab when user is following one budget investment at least" do
        create(:budget_investment, followers: [user])

        visit user_path(user)

        expect(page).to have_content("1 Following")
      end

      scenario "Display budget investment tab when user is following one budget investment at least" do
        create(:budget_investment, followers: [user])

        visit user_path(user, filter: "follows")

        expect(page).to have_link("Investments", href: "#investments")
      end

      scenario "Not display budget investment tab when user is not following any budget investment" do
        visit user_path(user, filter: "follows")

        expect(page).not_to have_link("Investments", href: "#investments")
      end

      scenario "Display budget investment with link to budget investment" do
        user = create(:user, :level_two)
        budget_investment = create(:budget_investment, author: user, followers: [user])

        visit user_path(user, filter: "follows")
        click_link "Investments"

        expect(page).to have_link budget_investment.title
      end
    end
  end

  describe "Initials" do
    scenario "display SVG avatars when loaded into the DOM", :js do
      login_as(create(:user))
      visit debate_path(create(:debate))

      fill_in "Leave your comment", with: "I'm awesome"
      click_button "Publish comment"

      within ".comment", text: "I'm awesome" do
        expect(page).to have_css "img.initialjs-avatar[src^='data:image/svg']"
      end
    end
  end
end
