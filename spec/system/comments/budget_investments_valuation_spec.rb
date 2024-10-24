require "rails_helper"

describe "Internal valuation comments on Budget::Investments" do
  let(:user) { create(:user) }
  let(:valuator_user) { create(:valuator).user }
  let(:admin_user) { create(:administrator).user }
  let(:budget) { create(:budget, :valuating) }
  let(:investment) { create(:budget_investment, budget: budget, valuators: [valuator_user.valuator]) }

  before do
    login_as(valuator_user)
  end

  context "Show valuation comments" do
    context "Show valuation comments without public comments" do
      before do
        public_comment = create(:comment, commentable: investment, body: "Public comment")
        create(:comment, commentable: investment, author: valuator_user,
                         body: "Public valuator comment")
        create(:comment, commentable: investment, author: admin_user, parent: public_comment)

        valuator_valuation = create(:comment, :valuation, commentable: investment,
                                                          author: valuator_user,
                                                          body: "Valuator Valuation")
        create(:comment, :valuation, commentable: investment, author: admin_user,
                                     body: "Admin Valuation")
        admin_response = create(:comment, :valuation, commentable: investment, author: admin_user,
                                                      body: "Admin Valuation response",
                                                      parent: valuator_valuation)
        create(:comment, :valuation, commentable: investment, author: admin_user,
                                     body: "Valuator Valuation response", parent: admin_response)
      end

      scenario "Valuation Show page without public comments" do
        visit valuation_budget_budget_investment_path(budget, investment)

        expect(page).not_to have_content("Comment as admin")
        expect(page).not_to have_content("Public comment")
        expect(page).not_to have_content("Public valuator comment")
        expect(page).to     have_content("Leave your comment")
        expect(page).to     have_content("Valuator Valuation")
        expect(page).to     have_content("Admin Valuation")
        expect(page).to     have_content("Admin Valuation response")
        expect(page).to     have_content("Valuator Valuation response")
      end

      scenario "Valuation Edit page without public comments" do
        visit edit_valuation_budget_budget_investment_path(budget, investment)

        expect(page).not_to have_content("Comment as admin")
        expect(page).not_to have_content("Public comment")
        expect(page).not_to have_content("Public valuator comment")
        expect(page).to     have_content("Leave your comment")
        expect(page).to     have_content("Valuator Valuation")
        expect(page).to     have_content("Admin Valuation")
        expect(page).to     have_content("Admin Valuation response")
        expect(page).to     have_content("Valuator Valuation response")
      end
    end
  end

  context "Valuation comment creation" do
    scenario "Normal users cannot create valuation comments altering public comments form" do
      comment = build(:comment, body: "HACKERMAN IS HERE", valuation: true, author: user)
      expect(comment).not_to be_valid
      expect(comment.errors.size).to eq(1)
    end

    scenario "Create comment" do
      visit valuation_budget_budget_investment_path(budget, investment)

      fill_in "Leave your comment", with: "Have you thought about...?"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content("Have you thought about...?")
      end

      visit budget_investment_path(investment.budget, investment)
      expect(page).not_to have_content("Have you thought about...?")
    end

    scenario "Reply to existing valuation" do
      comment = create(:comment, :valuation, author: admin_user, commentable: investment)

      login_as(valuator_user)
      visit valuation_budget_budget_investment_path(budget, investment)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "It will be done next week."
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "It will be done next week."
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"

      visit budget_investment_path(investment.budget, investment)
      expect(page).not_to have_content("It will be done next week.")
    end

    scenario "Multiple nested replies" do
      parent = create(:comment, :valuation, author: valuator_user, commentable: investment)

      7.times do
        create(:comment, :valuation, author: admin_user, commentable: investment, parent: parent)
        parent = parent.children.first
      end

      visit valuation_budget_budget_investment_path(budget, investment)
      expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")

      expect(page).not_to have_css(".comment-votes")
      expect(page).not_to have_css(".js-flag-actions")
      expect(page).not_to have_css(".moderation-actions")
    end
  end

  describe "Administrators" do
    scenario "can create valuation comment as an administrator" do
      login_as(admin_user)
      visit valuation_budget_budget_investment_path(budget, investment)

      fill_in "Leave your comment", with: "I am your Admin!"
      check "Comment as admin"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am your Admin!"
        expect(page).to have_content "Administrator ##{admin_user.administrator.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end
    end

    scenario "can create valuation reply as an administrator" do
      comment = create(:comment, :valuation, author: valuator_user, commentable: investment)

      login_as(admin_user)
      visit valuation_budget_budget_investment_path(budget, investment)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "Top of the world!"
        check "Comment as admin"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Top of the world!"
        expect(page).to have_content "Administrator ##{admin_user.administrator.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end
  end

  scenario "Send email notification" do
    ActionMailer::Base.deliveries = []

    login_as(admin_user)

    expect(ActionMailer::Base.deliveries).to eq([])

    visit valuation_budget_budget_investment_path(budget, investment)
    fill_in "Leave your comment", with: "I am your Admin!"
    check "Comment as admin"
    click_button "Publish comment"

    within "#comments" do
      expect(page).to have_content("I am your Admin!")
    end

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.first.to).to eq([valuator_user.email])
    expect(ActionMailer::Base.deliveries.first.subject).to eq("New evaluation comment")
  end
end
