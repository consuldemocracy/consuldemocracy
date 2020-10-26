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

    scenario "Collapsable comments", :js do
      parent_comment = create(:comment, :valuation, author: valuator_user, body: "Main comment",
                                                    commentable: investment)
      child_comment  = create(:comment, :valuation, author: valuator_user, body: "First subcomment",
                                                    commentable: investment, parent: parent_comment)
      grandchild_comment = create(:comment, :valuation, author: valuator_user,
                                                        parent: child_comment,
                                                        body: "Last child",
                                                        commentable: investment)

      visit valuation_budget_budget_investment_path(budget, investment)

      expect(page).to have_css(".comment", count: 3)
      expect(page).to have_content("1 response (collapse)", count: 2)

      within ".comment .comment", text: "First subcomment" do
        click_link text: "1 response (collapse)"
      end

      expect(page).to have_css(".comment", count: 2)
      expect(page).to have_content("1 response (collapse)")
      expect(page).to have_content("1 response (show)")
      expect(page).not_to have_content grandchild_comment.body

      within ".comment .comment", text: "First subcomment" do
        click_link text: "1 response (show)"
      end

      expect(page).to have_css(".comment", count: 3)
      expect(page).to have_content("1 response (collapse)", count: 2)
      expect(page).to have_content grandchild_comment.body

      within ".comment", text: "Main comment" do
        click_link text: "1 response (collapse)", match: :first
      end

      expect(page).to have_css(".comment", count: 1)
      expect(page).to have_content("1 response (show)")
      expect(page).not_to have_content child_comment.body
      expect(page).not_to have_content grandchild_comment.body
    end

    scenario "Comment order" do
      create(:comment, :valuation, commentable: investment,
                                   author: valuator_user,
                                   body: "Valuator Valuation",
                                   created_at: Time.current - 1)
      admin_valuation = create(:comment, :valuation, commentable: investment,
                                                     author: admin_user,
                                                     body: "Admin Valuation",
                                                     created_at: Time.current - 2)

      visit valuation_budget_budget_investment_path(budget, investment)

      expect(admin_valuation.body).to appear_before("Valuator Valuation")
    end

    scenario "Turns links into html links" do
      create(:comment, :valuation, author: admin_user, commentable: investment,
                                   body: "Check http://rubyonrails.org/")

      visit valuation_budget_budget_investment_path(budget, investment)

      within first(".comment") do
        expect(page).to have_content("Check http://rubyonrails.org/")
        expect(page).to have_link("http://rubyonrails.org/", href: "http://rubyonrails.org/")
        expect(find_link("http://rubyonrails.org/")[:rel]).to eq("nofollow")
        expect(find_link("http://rubyonrails.org/")[:target]).to eq("_blank")
      end
    end

    scenario "Sanitizes comment body for security" do
      comment_with_js = "<script>alert('hola')</script> <a href=\"javascript:alert('sorpresa!')\">"\
                        "click me<a/> http://www.url.com"
      create(:comment, :valuation, author: admin_user, commentable: investment,
                                   body: comment_with_js)

      visit valuation_budget_budget_investment_path(budget, investment)

      within first(".comment") do
        expect(page).to have_content("click me http://www.url.com")
        expect(page).to have_link("http://www.url.com", href: "http://www.url.com")
        expect(page).not_to have_link("click me")
      end
    end

    scenario "Paginated comments" do
      per_page = 10
      (per_page + 2).times do
        create(:comment, :valuation, commentable: investment, author: valuator_user)
      end

      visit valuation_budget_budget_investment_path(budget, investment)

      expect(page).to have_css(".comment", count: per_page)
      within("ul.pagination") do
        expect(page).to have_content("1")
        expect(page).to have_content("2")
        expect(page).not_to have_content("3")
        click_link "Next", exact: false
      end

      expect(page).to have_css(".comment", count: 2)
    end
  end

  context "Valuation comment creation" do
    scenario "Normal users cannot create valuation comments altering public comments form" do
      comment = build(:comment, body: "HACKERMAN IS HERE", valuation: true, author: user)
      expect(comment).not_to be_valid
      expect(comment.errors.size).to eq(1)
    end

    scenario "Create comment", :js do
      visit valuation_budget_budget_investment_path(budget, investment)

      fill_in "Leave your comment", with: "Have you thought about...?"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content("Have you thought about...?")
      end

      visit budget_investment_path(investment.budget, investment)
      expect(page).not_to have_content("Have you thought about...?")
    end

    scenario "Errors on create without comment text", :js do
      visit valuation_budget_budget_investment_path(budget, investment)

      click_button "Publish comment"

      expect(page).to have_content "Can't be blank"
    end

    scenario "Reply to existing valuation", :js do
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

      expect(page).not_to have_selector("#js-comment-form-comment_#{comment.id}")

      visit budget_investment_path(investment.budget, investment)
      expect(page).not_to have_content("It will be done next week.")
    end

    scenario "Reply update parent comment responses count", :js do
      comment = create(:comment, :valuation, author: admin_user, commentable: investment)

      login_as(valuator_user)
      visit valuation_budget_budget_investment_path(budget, investment)

      within ".comment", text: comment.body do
        click_link "Reply"
        fill_in "Leave your comment", with: "It will be done next week."
        click_button "Publish reply"

        expect(page).to have_content("1 response (collapse)")
      end
    end

    scenario "Reply show parent comments responses when hidden", :js do
      comment = create(:comment, :valuation, author: admin_user, commentable: investment)
      create(:comment, :valuation, author: admin_user, commentable: investment, parent: comment)

      login_as(valuator_user)
      visit valuation_budget_budget_investment_path(budget, investment)

      within ".comment", text: comment.body do
        click_link text: "1 response (collapse)"
        click_link "Reply"
        fill_in "Leave your comment", with: "It will be done next week."
        click_button "Publish reply"

        expect(page).to have_content("It will be done next week.")
      end
    end

    scenario "Errors on reply without comment text", :js do
      comment = create(:comment, :valuation, author: admin_user, commentable: investment)

      visit valuation_budget_budget_investment_path(budget, investment)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        click_button "Publish reply"
        expect(page).to have_content "Can't be blank"
      end
    end

    scenario "Multiple nested replies", :js do
      parent = create(:comment, :valuation, author: valuator_user, commentable: investment)

      7.times do
        create(:comment, :valuation, author: admin_user, commentable: investment, parent: parent)
        parent = parent.children.first
      end

      visit valuation_budget_budget_investment_path(budget, investment)
      expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")

      expect(page).to have_no_css(".comment-votes")
      expect(page).to have_no_css(".js-flag-actions")
      expect(page).to have_no_css(".js-moderation-actions")
    end
  end

  scenario "Erasing a comment's author" do
    comment = create(:comment, :valuation, author: valuator_user, commentable: investment,
                                           body: "this should be visible")
    comment.user.erase

    visit valuation_budget_budget_investment_path(budget, investment)
    within "#comment_#{comment.id}" do
      expect(page).to have_content("User deleted")
      expect(page).to have_content("this should be visible")
    end
  end

  describe "Administrators" do
    scenario "can create valuation comment as an administrator", :js do
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

    scenario "can create valuation reply as an administrator", :js do
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

      expect(page).not_to have_selector("#js-comment-form-comment_#{comment.id}")
    end
  end

  scenario "Send email notification", :js do
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
