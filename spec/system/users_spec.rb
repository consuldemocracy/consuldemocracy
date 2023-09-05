require "rails_helper"

describe "Users" do
  describe "Show (public page)" do
    let(:user) { create(:user) }

    let!(:debates)     { 1.times.map { create(:debate, author: user) } }
    let!(:proposals)   { 2.times.map { create(:proposal, author: user) } }
    let!(:investments) { 3.times.map { create(:budget_investment, author: user) } }
    let!(:comments)    { 4.times.map { create(:comment, user: user) } }

    scenario "shows user public activity" do
      visit user_path(user)

      expect(page).to have_content("1 Debate")
      expect(page).to have_content("2 Proposals")
      expect(page).to have_content("3 Investments")
      expect(page).to have_content("4 Comments")
    end

    scenario "shows only items where user has activity" do
      proposals.each(&:destroy)

      visit user_path(user)

      expect(page).not_to have_content("0 Proposals")
      expect(page).to have_content("1 Debate")
      expect(page).to have_content("3 Investments")
      expect(page).to have_content("4 Comments")
    end

    scenario "default filter is proposals" do
      visit user_path(user)

      proposals.each do |proposal|
        expect(page).to have_content(proposal.title)
      end

      debates.each do |debate|
        expect(page).not_to have_content(debate.title)
      end

      comments.each do |comment|
        expect(page).not_to have_content(comment.body)
      end
    end

    scenario "shows debates by default if user has no proposals" do
      proposals.each(&:destroy)

      visit user_path(user)

      expect(page).to have_content(debates.first.title)
    end

    scenario "shows investments by default if user has no proposals nor debates" do
      proposals.each(&:destroy)
      debates.each(&:destroy)

      visit user_path(user)

      expect(page).to have_content(investments.first.title)
    end

    scenario "shows comments by default if user has no proposals nor debates nor investments" do
      proposals.each(&:destroy)
      debates.each(&:destroy)
      investments.each(&:destroy)

      visit user_path(user)

      comments.each do |comment|
        expect(page).to have_content(comment.body)
      end
    end

    scenario "filters" do
      visit user_path(user)

      click_link "1 Debate"

      debates.each do |debate|
        expect(page).to have_content(debate.title)
      end

      proposals.each do |proposal|
        expect(page).not_to have_content(proposal.title)
      end

      comments.each do |comment|
        expect(page).not_to have_content(comment.body)
      end

      click_link "4 Comments"

      comments.each do |comment|
        expect(page).to have_content(comment.body)
      end

      proposals.each do |proposal|
        expect(page).not_to have_content(proposal.title)
      end

      debates.each do |debate|
        expect(page).not_to have_content(debate.title)
      end

      click_link "2 Proposals"

      proposals.each do |proposal|
        expect(page).to have_content(proposal.title)
      end

      comments.each do |comment|
        expect(page).not_to have_content(comment.body)
      end

      debates.each do |debate|
        expect(page).not_to have_content(debate.title)
      end
    end

    scenario "Show alert when user wants to delete a budget investment" do
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

    context "public interests is checked" do
      let(:user) { create(:user, public_interests: true) }

      scenario "can be accessed by anyone" do
        create(:proposal, followers: [user], title: "Others follow me")

        visit user_path(user, filter: "follows")

        expect(page).to have_content "1 Following"
        expect(page).to have_content "Others follow me"
      end

      scenario "Gracefully handle followables that have been hidden" do
        create(:proposal, followers: [user])
        create(:proposal, followers: [user], &:hide)

        visit user_path(user)

        expect(page).to have_content("1 Following")
      end

      scenario "displays generic interests title" do
        create(:proposal, tag_list: "Sport", followers: [user])

        visit user_path(user, filter: "follows", page: "1")

        expect(page).to have_content("Tags of elements this user follows")
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

          expect(page).to have_link "Citizen proposals", href: "#citizen_proposals"
          expect(page).to have_content proposal.title
        end

        scenario "Withdrawn proposals do not have a link to the dashboard" do
          proposal = create(:proposal, :retired, author: user)
          login_as user

          visit user_path(user)

          expect(page).to have_content proposal.title
          expect(page).not_to have_link "Dashboard"
          expect(page).to have_content "Dashboard not available for withdrawn proposals"
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

        scenario "Do not display budget investment tab when user is not following any budget investment" do
          visit user_path(user, filter: "follows")

          expect(page).not_to have_link("Investments", href: "#investments")
        end

        scenario "Display budget investment with link to budget investment" do
          budget_investment = create(:budget_investment, author: user, followers: [user])

          visit user_path(user, filter: "follows")

          expect(page).to have_link "Investments", href: "#investments"
          expect(page).to have_link budget_investment.title
        end
      end
    end

    context "public interests is not checked" do
      let(:user) { create(:user, public_interests: false) }

      scenario "can be accessed by its owner" do
        create(:proposal, followers: [user], title: "Follow me!")

        login_as(user)

        visit user_path(user, filter: "follows")

        expect(page).to have_content "1 Following"
        expect(page).to have_content "Follow me!"
        expect(page).to have_content "Tags of elements you follow"
      end

      scenario "cannot be accessed by anonymous users" do
        create(:proposal, followers: [user])

        visit user_path(user, filter: "follows")

        expect(page).to have_content "You do not have permission to access this page"
        expect(page).to have_current_path root_path
      end

      scenario "cannot be accessed by other users" do
        create(:proposal, followers: [user])

        login_as(create(:user))

        visit user_path(user, filter: "follows")

        expect(page).to have_content "You do not have permission to access this page"
        expect(page).to have_current_path root_path
      end

      scenario "cannot be accessed by administrators" do
        create(:proposal, followers: [user])

        login_as(create(:administrator).user)

        visit user_path(user, filter: "follows")

        expect(page).to have_content "You do not have permission to access this page"
        expect(page).to have_current_path root_path
      end
    end

    scenario "Display interests" do
      create(:proposal, tag_list: "Sport", followers: [user])

      login_as(user)
      visit account_path

      check "account_public_interests"
      click_button "Save changes"

      logout

      visit user_path(user, filter: "follows")

      expect(page).to have_css "#public_interests"
      expect(page).to have_content "Sport"
    end

    scenario "Do not display interests when proposal has been destroyed" do
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
  end

  describe "Initials" do
    scenario "display SVG avatars when loaded into the DOM" do
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
