require "rails_helper"

describe "Commenting Budget::Investments" do
  let(:investment) { create(:budget_investment) }

  it_behaves_like "flaggable", :budget_investment_comment

  describe "Administrators" do
    context "comment as administrator" do
      scenario "can create comment" do
        admin = create(:administrator)

        login_as(admin.user)
        visit budget_investment_path(investment.budget, investment)

        fill_in "Leave your comment", with: "I am your Admin!"
        check "comment-as-administrator-budget_investment_#{investment.id}"
        click_button "Publish comment"

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
          expect(page).to have_content "Administrator ##{admin.id}"
          expect(page).to have_css "div.is-admin"
          expect(page).to have_css "img.admin-avatar"
        end
      end

      scenario "display administrator description on admin views" do
        admin = create(:administrator, description: "user description")

        login_as(admin.user)

        visit admin_budget_budget_investment_path(investment.budget, investment)

        fill_in "Leave your comment", with: "I am your Admin!"
        check "comment-as-administrator-budget_investment_#{investment.id}"
        click_button "Publish comment"

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
        end

        visit admin_budget_budget_investment_path(investment.budget, investment)

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
          expect(page).to have_content "Administrator user description"
          expect(page).to have_css "div.is-admin"
          expect(page).to have_css "img.admin-avatar"
        end
      end

      scenario "display administrator id on public views" do
        admin = create(:administrator, description: "user description")

        login_as(admin.user)
        visit admin_budget_budget_investment_path(investment.budget, investment)

        fill_in "Leave your comment", with: "I am your Admin!"
        check "comment-as-administrator-budget_investment_#{investment.id}"
        click_button "Publish comment"

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
          expect(page).to have_content "Administrator ##{admin.id}"
          expect(page).to have_css "div.is-admin"
          expect(page).to have_css "img.admin-avatar"
        end
      end

      scenario "can create reply as an administrator" do
        citizen = create(:user, username: "Ana")
        manuela = create(:user, username: "Manuela")
        admin   = create(:administrator, user: manuela)
        comment = create(:comment, commentable: investment, user: citizen)

        login_as(manuela)
        visit budget_investment_path(investment.budget, investment)

        click_link "Reply"

        within "#js-comment-form-comment_#{comment.id}" do
          fill_in "Leave your comment", with: "Top of the world!"
          check "comment-as-administrator-comment_#{comment.id}"
          click_button "Publish reply"
        end

        within "#comment_#{comment.id}" do
          expect(page).to have_content "Top of the world!"
          expect(page).to have_content "Administrator ##{admin.id}"
          expect(page).to have_css "img.admin-avatar"
        end

        expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
        expect(page).to have_css "div.is-admin"
      end

      scenario "public users not see admin description" do
        manuela = create(:user, username: "Manuela")
        admin   = create(:administrator, user: manuela)
        comment = create(:comment,
                         commentable: investment,
                         user: manuela,
                         administrator_id: admin.id)

        visit budget_investment_path(investment.budget, investment)

        within "#comment_#{comment.id}" do
          expect(page).to have_content comment.body
          expect(page).to have_content "Administrator ##{admin.id}"
          expect(page).to have_css "img.admin-avatar"
          expect(page).to have_css "div.is-admin"
        end
      end
    end

    scenario "can not comment as a moderator", :admin do
      visit budget_investment_path(investment.budget, investment)

      expect(page).not_to have_content "Comment as moderator"
    end
  end

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:budget)     { create(:budget) }
    let(:investment) { create(:budget_investment, budget: budget) }
    let!(:comment)   { create(:comment, commentable: investment) }

    before do
      login_as(verified)
    end

    scenario "Show" do
      create(:vote, voter: verified, votable: comment, vote_flag: true)
      create(:vote, voter: unverified, votable: comment, vote_flag: false)

      visit budget_investment_path(budget, investment)

      within("#comment_#{comment.id}_votes") do
        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "2 votes"
      end
    end

    scenario "Create" do
      visit budget_investment_path(budget, investment)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Update" do
      visit budget_investment_path(budget, investment)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit budget_investment_path(budget, investment)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end
end
